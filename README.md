<h1 align="center">
  ⚙️ Dots
</h1>

<p align="center">
  configs, scripts, quality of life
</p>

## Usage

This is everything to set up my workstation. All that needs to be done is renaming the `secrets-template.nix` to `secrets.nix` and fill out the variables.

Afterwards only a single command is needed to set it up:

```bash
nixos-install
```

## Dotfiles

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
