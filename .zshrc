# Oh-my-zsh installation path
export ZSH=~/.oh-my-zsh

# Theme
ZSH_THEME="spaceship"

# Plugins
plugins=(git zsh-autosuggestions)

# User configuration
source $ZSH/oh-my-zsh.sh

alias upgrade='sudo dnf upgrade --refresh'
alias vim='nvim'
alias cat='bat'

alias h='cd --'
alias r='cd /'
alias d='cd ~/dev'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

alias dots='git --git-dir=$HOME/.dots/ --work-tree=$HOME'

# Go exports
export GOPATH=$HOME/dev/golang
export PATH=${PATH}:${GOPATH}/bin

# Rust exports
export PATH=${PATH}:${HOME}/.cargo/bin

# Fix autosuggest highlight color on urxvt
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=15"
