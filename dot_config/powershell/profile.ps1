# XDG-equivalent environment variables
$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:XDG_DATA_HOME   = "$HOME/.local/share"
$env:XDG_CACHE_HOME  = "$HOME/.cache"
$env:PATH            = "$HOME/.config/bin" + [IO.Path]::PathSeparator + $env:PATH

# Set output encoding for external commands (e.g., piping to cmd.exe tools)  
$OutputEncoding = [System.Text.UTF8Encoding]::new()  
 
# Set console display encoding  
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()  
 
# Force cmdlets like Out-File and Set-Content to use UTF-8 (no BOM)  
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'  
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'  
$PSDefaultParameterValues['Export-Csv:Encoding'] = 'utf8'

# Eza (modern ls replacement)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls  { eza -ax --icons @args }
    function ll  { eza -albh --icons --git @args }
    function lr  { eza -TL 3 --icons @args }
}

# Starship prompt (requires Starship installed via winget)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Zoxide (smarter cd with z alias) — must come after Starship so it wraps Starship's prompt hook
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# git-aliases (installed via scoop; on PSModulePath). No-op if not installed.
Import-Module git-aliases -DisableNameChecking -ErrorAction SilentlyContinue

# Salmon (music uploads via docker compose on truenas)
$SalmonCompose = "/mnt/apps/stacks/smoked-salmon/compose.yaml"
$SalmonDrive   = "M:\"
$SalmonInbox   = "M:\downloads"
$SalmonConfig  = "/mnt/apps/stacks/smoked-salmon/config/config.toml"

# Start an upload. A folder already on M: is used where it is; anything else is copied to M:\downloads first.
function salmon-up {
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Source = "WEB",
        [Parameter(ValueFromRemainingArguments)][string[]]$Extra
    )
    $item = Get-Item -LiteralPath $Path
    $full = $item.FullName.TrimEnd('\')

    if ($full -like "$SalmonDrive*") {
        # Already on the server: translate M:\downloads\... or M:\uploads\... to the container's /data/... path
        $relative = $full.Substring($SalmonDrive.Length) -replace '\\', '/'
        if ($relative -notmatch '^(downloads|uploads)(/.+)$') {
            throw "Salmon can only see folders inside M:\downloads and M:\uploads."
        }
        $remotePath = "/data/" + $Matches[1].ToLower() + $Matches[2]
    } else {
        robocopy $full (Join-Path $SalmonInbox $item.Name) /E /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy failed (exit $LASTEXITCODE)" }
        $remotePath = "/data/downloads/" + $item.Name
    }

    $remotePath = $remotePath -replace "'", "'\''"
    $cmd = "sudo docker compose -f $SalmonCompose run --rm salmon up '$remotePath' -s $Source $($Extra -join ' ')"
    ssh -t truenas $cmd
}

function sup {
    salmon-up @args
}

# Other salmon commands that don't take a path: salmon checkconf, salmon health, salmon --help
function salmon {
    ssh -t truenas "sudo docker compose -f $SalmonCompose run --rm salmon $($args -join ' ')"
}

# Replace the RED/OPS session cookies in the salmon config. Leave a prompt blank to keep that tracker's current value.
# The new values travel over ssh stdin, so they never land in shell history or a process list.
function salmon-session {
    $new = @{}
    foreach ($tracker in "red", "ops") {
        $secure = Read-Host "New $($tracker.ToUpper()) session (blank to keep)" -AsSecureString
        $plain = [System.Net.NetworkCredential]::new("", $secure).Password
        if ($plain) { $new["tracker.$tracker"] = $plain.Trim() }
    }
    if (-not $new.Count) { Write-Host "Nothing to change."; return }

    $payload = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $new -Compress)))
    $script = @'
import base64, json, re, sys
path = "__PATH__"
new = json.loads(base64.b64decode("__PAYLOAD__"))
with open(path) as f:
    lines = f.readlines()
section, done = None, set()
for i, line in enumerate(lines):
    m = re.match(r"\s*\[\[?\s*([^\]]+?)\s*\]\]?", line)
    if m:
        section = m.group(1)
    elif section in new and section not in done and re.match(r"\s*session\s*=", line):
        lines[i] = "session = " + json.dumps(new[section]) + "\n"
        done.add(section)
missing = sorted(set(new) - done)
if missing:
    sys.exit("No session line found under: " + ", ".join(missing))
with open(path, "w") as f:
    f.writelines(lines)
print("Updated: " + ", ".join(sorted(done)))
'@
    $script.Replace("__PATH__", $SalmonConfig).Replace("__PAYLOAD__", $payload) | ssh truenas python3 -
}
