#!/bin/bash

echo "Start linking ..."

OBSIDIAN_DIR="$HOME/obsidian/my obsidian"

cd $(dirname $0)/..

if [[ "$OSTYPE" == "darwin"* ]]; then
  ln -sf $(realpath ./.config/alacritty) ~/.config/alacritty
  ln -sf $(realpath ./.config/fish) ~/.config/fish
  ln -sf $(realpath ./.config/git/.gitconfig) ~/.gitconfig
  ln -sf $(realpath ./.config/git/.git-aliases) ~/.git-aliases
  ln -sf $(realpath ./.config/nvim) ~/.config/nvim
  ln -sf $(realpath ./.config/tmux/.tmux.conf) ~/.tmux.conf
  # ln -sf $(realpath "$OBSIDIAN_DIR"/.vimrc) ~/.vimrc
fi


echo "Finish linking"

