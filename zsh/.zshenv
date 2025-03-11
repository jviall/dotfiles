if [[ -z "$XDG_CONFIG_HOME" ]]
then
        export XDG_CONFIG_HOME="$HOME/.config/"
fi
if [[ -z "$XDG_DATA_HOME" ]]
then
        export XDG_DATA_HOME="$HOME/.local/share/"
fi
if [[ -z "$XDG_CACHE_HOME" ]]
then
        export XDG_CACHE_HOME="$HOME/.cache/"
fi
# set location of .zshrc if present
if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
        export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
fi

# Hombrew path
export PATH="$HOME/brew/bin:$PATH"
export HOMEBREW_BREWFILE="$XDG_CONFIG_HOME/homebrew/Brewfile"

# if exists source secrets
[ -f "${XDG_CONFIG_HOME}/secrets/.env" ] && source "${XDG_CONFIG_HOME}/secrets/.env"
