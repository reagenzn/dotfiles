#!/bin/bash -eux

echo "Setting up Python environment with pyenv..."

# pyenvが既にインストールされているかチェック
if ! command -v pyenv &> /dev/null; then
    echo "Error: pyenv is not installed. Please run 'make setup-mac' first."
    exit 1
fi

# pyenvのshimsディレクトリが存在するか確認
if [ ! -d "$HOME/.pyenv" ]; then
    echo "Initializing pyenv..."
    # pyenvの初期化（必要に応じて）
    eval "$(pyenv init -)"
fi

# 推奨されるPythonバージョン
PYTHON_VERSION="3.11.13"

# 指定されたPythonバージョンがインストールされているかチェック
if ! pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"; then
    echo "Installing Python ${PYTHON_VERSION}..."
    pyenv install ${PYTHON_VERSION}
else
    echo "Python ${PYTHON_VERSION} is already installed."
fi

# グローバルバージョンを設定
echo "Setting Python ${PYTHON_VERSION} as global default..."
pyenv global ${PYTHON_VERSION}

# pyenvのPATHを一時的に設定
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# pynvimモジュールをインストール
echo "Installing pynvim module..."
if ! python -c "import pynvim" 2>/dev/null; then
    # SSL証明書の問題を回避してインストール
    pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org pynvim
    echo "pynvim installed successfully."
else
    echo "pynvim is already installed."
fi

# インストール確認
python -c "import pynvim; print('✓ pynvim module is available')"

echo "Python environment setup completed!"
