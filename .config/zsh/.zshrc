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
DISABLE_MAGIC_FUNCTIONS="true"
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

# fzf で祖先ディレクトリを選んで cd する。
# fzf-cd-widget (Alt-C) はカレント配下しか見ないため、上方向はこちらを使う。
function fzf-cd-parent-widget() {
  local dir=$PWD ancestors=()
  while [[ $dir != / ]]; do
    dir=${dir:h}
    ancestors+=("$dir")
  done

  local selected
  selected=$(printf '%s\n' "${ancestors[@]}" \
    | FZF_DEFAULT_OPTS="--height 40% --reverse --prompt='親ディレクトリ> '" fzf) || return 0

  [[ -n $selected ]] || return 0
  builtin cd -- "$selected"
  zle reset-prompt
}
zle -N fzf-cd-parent-widget

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

  # 祖先ディレクトリへ cd（Alt-C の逆方向）。
  # Alt+Up は端末が CSI を送らない場合があるため Alt-K も併用する。
  bindkey -M viins '^[[1;3A' fzf-cd-parent-widget
  bindkey -M vicmd '^[[1;3A' fzf-cd-parent-widget
  bindkey -M viins '^[k' fzf-cd-parent-widget
  bindkey -M vicmd '^[k' fzf-cd-parent-widget
}

# Aliases
alias ls='ls -G'
alias ll='ls -lah'
alias la='ls -a'
alias e='exit'
alias c='clear'
alias g='git'
alias reload='source ~/.zshrc'
alias cc='claude'
alias edot='nvim ~/dotfiles'

# worktree setup
alias setup-worktrees='~/dotfiles/scripts/setup-worktrees.sh'

# gwt (git worktree runner)
alias gwn='git gtr new'
alias gwe='git gtr editor'
alias gwa='git gtr ai'
alias gwl='git gtr list'
alias gwrm='git gtr rm'
alias gwc='git gtr clean --merged'

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

. "$HOME/.local/bin/env"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# mise
eval "$(mise activate zsh)"
# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

# sentry
fpath=("/Users/natsuki.fukazawa/.local/share/zsh/site-functions" $fpath)

# sentry
export PATH="/Users/natsuki.fukazawa/.sentry/bin:$PATH"

# Claude Code multi-account
alias claude-ent='CLAUDE_CONFIG_DIR=$HOME/.claude-enterprise command claude'
