# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zsh configuration

# Oh My Zsh installation path
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_reduce_blanks

# Plugins
plugins=(
  git
  docker
  node
  npm
  yarn
  brew
  z
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# zsh-vi-mode custom keybindings
# This function is called after zsh-vi-mode initialization
function zvm_after_init() {
  # Re-source fzf keybindings if available
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  
  # Bind Ctrl+R for fzf history search in both modes
  bindkey -M viins '^R' fzf-history-widget
  bindkey -M vicmd '^R' fzf-history-widget
  
  # Bind Ctrl+W for backward-kill-word in both modes
  bindkey -M viins '^W' backward-kill-word
  bindkey -M vicmd '^W' backward-kill-word
  
  # Additional useful bindings for normal mode
  bindkey -M vicmd '^A' beginning-of-line
  bindkey -M vicmd '^E' end-of-line
}

# Aliases
alias ls='ls -G'
alias ll='ls -lah'
alias la='ls -a'
alias e='exit'
alias c='clear'
alias g='git'
alias reload='source ~/.zshrc'

# Path
export PATH="$HOME/bin:$PATH"

# Powerlevel10k custom segments
# Node.js version segment
function prompt_my_node() {
  if command -v node &> /dev/null; then
    local node_version=$(node -v 2>/dev/null)
    if [[ -n "$node_version" ]]; then
      p10k segment -f 2 -i '⬢' -t "${node_version}"
    fi
  fi
}

# AWS region segment
function prompt_my_aws() {
  if command -v aws &> /dev/null; then
    local aws_region=$(aws configure get region 2>/dev/null)
    if [[ -n "$aws_region" ]]; then
      p10k segment -f 3 -i '☁' -t "${aws_region}"
    fi
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
