<h1 align="center">
  ⚙️ Dots
</h1>

<p align="center">
  configs, scripts, quality of life
</p>

## Setup
The dotfiles setup is based on the concept from [jaagr](https://github.com/jaagr/dots). Basically everything is managed with a git repository and the `dots` alias.
### Alias
```sh
alias dots='git --git-dir=$HOME/.dots/ --work-tree=$HOME'
```

### Setup
```sh
git init --bare $HOME/.dots
dots remote add origin https://github.com/Algram/dots.git
```

### Configuration
```sh
dots config status.showUntrackedFiles no
```

### Usage
```sh
# Use the dots alias like you would use the git command
dots status
dots add --update ...
dots commit -m "..."
dots push

# Listing files (tracked by git)
dots ls-files
dots ls-files .config/polybar/
```

### Replication
```sh
git clone --recursive --separate-git-dir=$HOME/.dots https://github.com/Algram/dots.git /tmp/dots
rsync -rvl --exclude ".git" /tmp/dots/ $HOME/
rm -r /tmp/dots
dots submodule update --init --recursive $HOME/
```

## Wallpaper
- https://unsplash.com/photos/Z4wF0h47fy8
- https://unsplash.com/photos/VNseEaTt9w4
- https://unsplash.com/photos/JgOeRuGD_Y4

## Applications (Sway)
- mako (Notifications)
- slurp
- grim
- wl-clipboard
- waybar
- https://github.com/yory8/clipman
- https://github.com/vlevit/notify-send.sh
- https://github.com/Bluedrack28/vscode-wal
- pywal

## Applications
- bspwm
- sxhkd
- polybar
- compton (https://github.com/yshui/compton)
- dunst, dunstify
- rofi
- rofi-plugin-calc
- rofi-plugin-emoji
- clipmenu
- i3lock-color (https://github.com/PandorasFox/i3lock-color)
- materia-light-compact (gtk-theme)
- numix-circle (icon-theme)
- urxvt256c
- maim
- feh
- razercfg
- zsh
- oh-my-zsh
- bat
- redshift
- translate-shell
- mpv
- qalculate
- gopass
- streamlink
- gsimplecal
- nerdfonts (Roboto Mono)
- tldr
- notable
- syncthing
- fd
- fx
