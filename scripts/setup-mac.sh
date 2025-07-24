#!/bin/bash -eux
echo "Start setup ..."

if [ $(uname) = Darwin ]; then
    if ! type brew &> /dev/null ; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Since Homebrew is already installed, skip this phase and proceed."
    fi
    brew bundle install --file=./.config/mac/Brewfile
    
    # Python環境のセットアップ
    echo "Setting up Python environment..."
    ./scripts/setup-python.sh
    
    # Fish設定のセットアップ
    echo "Setting up fish shell configuration..."
    ./scripts/setup-fish.sh
fi