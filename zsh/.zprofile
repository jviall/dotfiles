#!/bin/zsh
# Hombrew path
export PATH="/opt/homebrew/bin:$PATH"
export HOMEBREW_BREWFILE="$XDG_CONFIG_HOME/homebrew/Brewfile"

# if exists source secrets
[ -f "${XDG_CONFIG_HOME}/secrets/.env" ] && source "${XDG_CONFIG_HOME}/secrets/.env"

# if exists add config/bin to PATH
if [ -d "${XDG_CONFIG_HOME}/bin" ]; then
  export PATH="$XDG_CONFIG_HOME/bin:$PATH"
fi

# if exists use local homebrew
if [ -d "$HOME/brew/bin" ]; then
  export PATH="$HOME/brew/bin:$PATH"
fi

export PATH="/opt/homebrew/bin/python3:$PATH"
export PATH="/opt/homebrew/opt/python3/libexec/bin:$PATH"

# Added by `rbenv init` on Fri Apr  4 10:42:21 PDT 2025
eval "$(rbenv init - --no-rehash zsh)"

# Created by `pipx` on 2025-04-20 02:16:04
export PATH="$PATH:/Users/jamesviall/.local/bin"

# Created by `pipx` on 2025-07-21 23:06:01
export PATH="$PATH:/Users/njooi/.local/bin"
