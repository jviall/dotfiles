# XDG-equivalent environment variables
$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:XDG_DATA_HOME   = "$HOME/.local/share"
$env:XDG_CACHE_HOME  = "$HOME/.cache"
$env:PATH            = "$HOME/.config/bin" + [IO.Path]::PathSeparator + $env:PATH

# Eza (modern ls replacement)
if (Get-Command eza -ErrorAction Continue) {
    function ls  { eza -ax --icons @args }
    function ll  { eza -albh --icons --git @args }
    function lr  { eza -TL 3 --icons @args }
}

# Starship prompt (requires Starship installed via winget)
if (Get-Command starship -ErrorAction Continue) {
    Invoke-Expression (&starship init powershell)
}

# Zoxide (smarter cd with z alias) — must come after Starship so it wraps Starship's prompt hook
if (Get-Command zoxide -ErrorAction Continue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if(scoop list $pkg 2>&1 | Select-String 'git-aliases') {
  Import-Module git-aliases -DisableNameChecking
}
