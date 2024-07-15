#!/bin/bash

echo "Start linking ..."

OBSIDIAN_DIR="$HOME/obsidian/my\ obsidian"

cd $(dirname $0)/..

if [[ "$OSTYPE" == "darwin"* ]]; then
  ln -sf $(realpath ./.config/alacritty) ~/.config
  ln -sf $(realpath ./.config/fish) ~/.config
  ln -sf $(realpath ./.config/git/.gitconfig) ~/.gitconfig
  ln -sf $(realpath ./.config/git/.git-aliases) ~/.git-aliases
  ln -sf $(realpath ./.config/nvim) ~/.config
  ln -sf $(realpath ./.config/tmux/.tmux.conf) ~/.tmux.conf
  ln -sf $(realpath ./.config/tmux/.tmux.mac.conf) ~/.tmux.mac.conf
  ln -sf $(realpath ./.config/vscode/keybindings.json) ~/Library/Application\ Support/Cursor/User/keybindings.json
  # ln -sf $(realpath "$OBSIDIAN_DIR"/.vimrc) ~/.vimrc
fi


echo "Finish linking"

