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
$SalmonCompose = "/mnt/apps/stacks/music-upload/compose.yaml"
$SalmonSmb     = "M:\downloads"
$SalmonRemote  = "/data/downloads"

# Copy a release to downloads (if it isn't there already) and start an upload
function Salmon-Up {
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Source = "WEB",
        [Parameter(ValueFromRemainingArguments)][string[]]$Extra
    )
    $item = Get-Item -LiteralPath $Path
    $name = $item.Name

    if ($item.FullName -notlike "$SalmonSmb*") {
        robocopy $item.FullName (Join-Path $SalmonSmb $name) /E /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy failed (exit $LASTEXITCODE)" }
    }

    $remotePath = "$SalmonRemote/$name" -replace "'", "'\''"
    $cmd = "sudo docker compose -f $SalmonCompose run --rm salmon up '$remotePath' -s $Source $($Extra -join ' ')"
    ssh -t truenas $cmd
}

# Run any other salmon command: salmon checkconf, salmon health, salmon --help
function salmon {
    ssh -t truenas "sudo docker compose -f $SalmonCompose run --rm salmon $($args -join ' ')"
}
