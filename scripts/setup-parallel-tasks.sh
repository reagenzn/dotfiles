#!/bin/bash

set -e

echo "Setting up parallel-tasks repository..."

# Clone or update parallel-tasks repository
if [ ! -d "$HOME/parallel-tasks" ]; then
    echo "Cloning parallel-tasks repository..."
    git clone git@github.com:$USER/parallel-tasks.git "$HOME/parallel-tasks"
else
    echo "parallel-tasks already exists, pulling latest changes..."
    cd "$HOME/parallel-tasks" && git pull origin main
fi

# Setup setup.sh and add to PATH
if [ -f "$HOME/parallel-tasks/setup.sh" ]; then
    echo "Making setup.sh executable..."
    chmod +x "$HOME/parallel-tasks/setup.sh"
    
    echo "Adding parallel-tasks to PATH..."
    
    # Add to .bashrc if it exists or create it
    if [ ! -f "$HOME/.bashrc" ] || ! grep -q "parallel-tasks" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/parallel-tasks:$PATH"' >> "$HOME/.bashrc"
    fi
    
    # Add to .zshrc if it exists or create it
    if [ ! -f "$HOME/.zshrc" ] || ! grep -q "parallel-tasks" "$HOME/.zshrc"; then
        echo 'export PATH="$HOME/parallel-tasks:$PATH"' >> "$HOME/.zshrc"
    fi
    
    # Add to fish config if fish is installed
    if command -v fish >/dev/null 2>&1; then
        mkdir -p "$HOME/.config/fish"
        if [ ! -f "$HOME/.config/fish/config.fish" ] || ! grep -q "parallel-tasks" "$HOME/.config/fish/config.fish"; then
            echo 'set -gx PATH $HOME/parallel-tasks $PATH' >> "$HOME/.config/fish/config.fish"
        fi
    fi
    
    echo "parallel-tasks setup completed!"
else
    echo "Error: setup.sh not found in parallel-tasks repository"
    exit 1
fi
