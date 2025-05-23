#!/bin/zsh
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config//zsh//.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Download Znap, if it's not there yet.
[[ -r ${XDG_CONFIG_HOME}/zsh/plugins/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ${XDG_CONFIG_HOME}/zsh/plugins
zstyle ':znap:*' repos-dir ${XDG_CONFIG_HOME}/zsh/plugins
# Start Znap
source ${XDG_CONFIG_HOME}/zsh/plugins/znap.zsh

autoload -U compinit -u; compinit -u

# if exists source vicmd
[ -f "${ZDOTDIR}/vimrc" ] && source "${ZDOTDIR}/vimrc"
# if exists source plugins 
[ -f "${ZDOTDIR}/pluginrc" ] && source "${ZDOTDIR}/pluginrc"
# if exists source aliases
[ -f "${ZDOTDIR}/aliasrc" ] && source "${ZDOTDIR}/aliasrc"
# if exists source options
[ -f "${ZDOTDIR}/optionrc" ] && source "${ZDOTDIR}/optionrc"

## Do customizations below here ##
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# history
HISTSIZE=110000
SAVEHIST=100000
HISTFILE=${XDG_CACHE_HOME}/zsh/.zsh_history

export VISUAL=/usr/local/bin/nvim
export EDITOR=/usr/local/bin/nvim

# FNM
eval "$(fnm env --use-on-cd)"

# zoxide
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.config//zsh//.p10k.zsh.
# Keep towards bottom
[[ ! -f ~/.config//zsh//.p10k.zsh ]] || source ~/.config//zsh//.p10k.zsh

