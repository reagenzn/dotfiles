#!/bin/bash

# Install fish shell
if [[ "$OSTYPE" == "darwin"* ]]; then

  if ! whick fish > /dev/null 2>&1; then
    brew install fish
  fi

  if ! which fisher > /dev/null 2>&1; then
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    fisher update
  fi
fi
