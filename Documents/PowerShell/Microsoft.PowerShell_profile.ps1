# XDG-equivalent environment variables
$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:XDG_DATA_HOME   = "$HOME/.local/share"
$env:XDG_CACHE_HOME  = "$HOME/.cache"
$env:PATH            = "$HOME/.config/bin" + [IO.Path]::PathSeparator + $env:PATH

# Git aliases
function gs    { git status }
function ga    { git add @args }
function gaa   { git add -A }
function gap   { git add -p }
function gd    { git diff @args }
function gdc   { git diff --cached }
function gst   { git stash @args }
function gch   { git checkout @args }
function gnb   { git checkout -b @args }
function gpull { git pull }
function gc    { git commit -S @args }
function gcm   { git commit -S -m @args }
function gca   { git commit -S -a @args }
function gcam  { git commit -S -am @args }
function gce   { git commit -S --amend @args }
function gl {
    git log --pretty=format:'%C(yellow)%h%Creset %ad %C(cyan)%an%Creset: %s' --date=relative -n 10
}
function gll {
    git log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative
}
function g {
    if ($args.Count -eq 0) { git status } else { git @args }
}

# Starship prompt (requires Starship installed via winget)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
