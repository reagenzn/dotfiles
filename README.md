# setup

## macOS Setup Guide

This guide outlines the steps to set up your development environment on macOS after cloning this repository.

1.  **Clone the Repository**
    *   Start by cloning this repository to your local machine if you haven't already.

2.  **Run `make setup-mac`**
    *   This command automates the initial software installation.
    *   It first ensures Homebrew (a package manager for macOS) is installed.
    *   Then, it uses Homebrew to install a collection of command-line tools and GUI applications defined in `.config/mac/Brewfile`. Key installations include:
        *   CLI Tools: `ansible`, `curl`, `fish` (shell), `fzf` (fuzzy finder), `gh` (GitHub CLI), `neovim` (text editor), `tmux` (terminal multiplexer), `tree`, `wget`, `lazygit`.
        *   GUI Applications: `alt-tab` (window switcher), `font-hack-nerd-font` (font), `rectangle` (window manager).
    *   Execute the command:
        ```bash
        make setup-mac
        ```

3.  **Run `make install`**
    *   This command handles further software setup, primarily for the Fish shell and other development tools.
    *   Ensures `fish` shell is installed (it would typically be installed by `make setup-mac`; Homebrew will confirm if it's already present or install it otherwise).
    *   It installs `fisher`, a plugin manager for Fish, and then uses it to install and update Fish shell plugins.
    *   It changes your default shell to `fish`. You might need to restart your terminal or open a new session for this change to take effect.
    *   It installs `volta`, a manager for JavaScript tools (like Node, npm, Yarn).
    *   It installs `tpm` (Tmux Plugin Manager) by cloning its repository if it's not already present.
    *   Execute the command:
        ```bash
        make install
        ```

4.  **Run `make link`**
    *   This command sets up your configuration files (dotfiles).
    *   It creates symbolic links from the configuration files within this repository to their standard locations in your home directory (e.g., `~/.config/`, `~/.gitconfig`).
    *   This step applies the custom configurations for tools such as Alacritty (terminal), Fish (shell), Git, Neovim (editor), Tmux, and VSCode keybindings.
    *   Execute the command:
        ```bash
        make link
        ```

5.  **Configure Git User**
    *   Create a `.git-user` file in your home directory. This file is intended for your local Git user configuration (name and email), which can be used to override global Git settings for repositories in this setup.
        ```bash
        touch ~/.git-user
        ```
    *   You should then edit this file to include your Git username and email, for example:
        ```
        [user]
            name = Your Name
            email = your.email@example.com
        ```

6.  **Manual Application Installations**
    *   The following applications are not installed by the automated scripts and need to be installed manually from their respective websites or other sources:
        *   Obsidian
        *   Alacritty
        *   Visual Studio Code (VSCode)
        *   Raycast

7.  **Export/Import Application Settings**
    *   These are manual steps for specific application settings:
        *   **Chrome Extensions:** Export/import your Chrome browser extensions or rely on Chrome's sync feature.
        *   **Raycast, Vimium:** These applications have options to export and import their settings. It's recommended to do this to maintain your preferences.