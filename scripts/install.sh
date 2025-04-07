#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then

  if ! whick fish > /dev/null 2>&1; then
    brew install fish
  fi

  if ! which fisher > /dev/null 2>&1; then
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    fisher update
  fi

  # Changing default shell to fish
  echo 'Changing default shell to fish'
  echo "$(which fish)" | sudo tee -a /etc/shells
  chsh -s "$(which fish)"
  
  # Install volta
  if ! which volta > /dev/null 2>&1; then
    curl https://get.volta.sh | bash
  fi

  # Install tpm
  if [ ! -d "~/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

fi
