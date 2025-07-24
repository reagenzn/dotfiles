#!/bin/bash -eux

echo "Setting up fish shell configuration for pyenv..."

# fish設定ディレクトリを作成（存在しない場合）
FISH_CONFIG_DIR="$HOME/.config/fish"
if [ ! -d "$FISH_CONFIG_DIR" ]; then
    echo "Creating fish config directory..."
    mkdir -p "$FISH_CONFIG_DIR"
fi

# fish設定ファイルのパス
FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"

# pyenv設定がすでに存在するかチェック
if [ -f "$FISH_CONFIG_FILE" ] && grep -q "PYENV_ROOT" "$FISH_CONFIG_FILE"; then
    echo "pyenv configuration already exists in fish config."
else
    echo "Adding pyenv configuration to fish config..."
    
    # pyenv設定をfish設定ファイルに追加
    cat >> "$FISH_CONFIG_FILE" << 'EOF'

# pyenv configuration
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - | source
EOF
    
    echo "pyenv configuration added to fish config."
fi

echo "Fish shell configuration completed!"
echo "Please restart your terminal or run 'source ~/.config/fish/config.fish' to apply changes."
