#!/bin/bash

echo "Start linking ..."

OBSIDIAN_DIR="$HOME/obsidian/myObsidian"

cd $(dirname $0)/..

if [[ "$OSTYPE" == "darwin"* ]]; then
  ln -sf $(realpath ./.config/alacritty) ~/.config
  ln -sf $(realpath ./.config/fish) ~/.config
  ln -sf $(realpath ./.config/git/.gitconfig) ~/.gitconfig
  ln -sf $(realpath ./.config/git/.git-aliases) ~/.git-aliases
  ln -sf $(realpath ./.config/nvim) ~/.config
  ln -sf $(realpath ./.config/tmux/.tmux.conf) ~/.tmux.conf
  ln -sf $(realpath ./.config/tmux/.tmux.mac.conf) ~/.tmux.mac.conf
  ln -sf $(realpath ./.config/zsh/.zshrc) ~/.zshrc
  ln -sf $(realpath ./.config/zsh/.p10k.zsh) ~/.p10k.zsh
  ln -sf $(realpath ./.config/.copilot) ~/
  rm -rf ~/.claude/skills && ln -sf $(realpath ./.config/.claude/skills) ~/.claude/skills
  # ln -sf $(realpath ./.config/vscode/keybindings.json) ~/Library/Application\ Support/Cursor/User/keybindings.json
  ln -sf $(realpath ./.config/vscode/keybindings.json) ~/Library/Application\ Support/Code/User/keybindings.json
  ln -sf $(realpath ./.config/obsidian/.obsidianvimrc) $OBSIDIAN_DIR/.vimrc

  # git-gtr: coreutils の gtr と衝突するため git-gtr のみリンク
  if [ -f /opt/homebrew/Cellar/git-gtr/*/bin/git-gtr ]; then
    ln -sf /opt/homebrew/Cellar/git-gtr/*/bin/git-gtr /opt/homebrew/bin/git-gtr
  fi
fi


echo "Finish linking"

