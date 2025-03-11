#!/bin/zsh
# Hombrew path
export PATH="/opt/homebrew/bin:$PATH"
export HOMEBREW_BREWFILE="$XDG_CONFIG_HOME/homebrew/Brewfile"
export PATH="/opt/homebrew/opt/python3/libexec/bin:$PATH"

# if exists source secrets
[ -f "${XDG_CONFIG_HOME}/secrets/.env" ] && source "${XDG_CONFIG_HOME}/secrets/.env"

# if exists add config/bin to PATH
[ -d "${XDG_CONFIG_HOME}/bin" ] && export PATH="$XDG_CONFIG_HOME}/bin:$PATH"
# if exists use local homebrew
if [ -d "$HOME/brew/bin" ]; then
  export PATH="$HOME/brew/bin:$PATH"
  export PATH="$HOME/brew/opt/python3/libexec/bin:$PATH"
fi
