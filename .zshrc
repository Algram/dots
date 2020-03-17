# Oh-my-zsh installation path
export ZSH=~/.oh-my-zsh

# Theme
ZSH_THEME="spaceship"

# Plugins
plugins=(git zsh-autosuggestions z)

# User configuration
source $ZSH/oh-my-zsh.sh

alias upgrade='sudo dnf upgrade --refresh'
alias cat='bat'
alias tldr='tldr --theme ocean'
alias dots='git --git-dir=$HOME/.dots/ --work-tree=$HOME'

# Quality of life
alias h='cd --'
alias r='cd /'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

alias dc='docker-compose'
alias config='vim ~/.zshrc'

# Go exports
export GOPATH=$HOME/dev/golang
export PATH=${PATH}:${GOPATH}/bin

# Rust exports
export PATH=${PATH}:${HOME}/.cargo/bin

export PATH=${PATH}:${HOME}/Downloads/sdcc-9948_mcs51/bin

# Fix autosuggest highlight color on urxvt
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=15"

export PATH="${PATH}:${HOME}/.local/bin/"
