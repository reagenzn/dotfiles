#!/bin/bash -eux

echo "Setting up zsh with Oh My Zsh and plugins..."

# Oh My Zshのインストール
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "Oh My Zsh installed successfully."
else
    echo "Oh My Zsh is already installed."
fi

# カスタムプラグインディレクトリのパス
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestionsのインストール
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo "zsh-autosuggestions installed successfully."
else
    echo "zsh-autosuggestions is already installed."
fi

# zsh-syntax-highlightingのインストール
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo "zsh-syntax-highlighting installed successfully."
else
    echo "zsh-syntax-highlighting is already installed."
fi

# zsh-vi-modeのインストール
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-vi-mode" ]; then
    echo "Installing zsh-vi-mode..."
    git clone https://github.com/jeffreytse/zsh-vi-mode "$ZSH_CUSTOM/plugins/zsh-vi-mode"
    echo "zsh-vi-mode installed successfully."
else
    echo "zsh-vi-mode is already installed."
fi

# powerlevel10kテーマのインストール
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    echo "powerlevel10k theme installed successfully."
else
    echo "powerlevel10k theme is already installed."
fi

echo "Zsh setup completed successfully!"
echo "Please run 'source ~/.zshrc' or restart your terminal to apply changes."
