#view
set -g theme_display_git_default_branch yes
set -g theme_color_scheme dark
set -g theme_display_vi yes

#path
set -x PATH $HOME/.nodebrew/current/bin $PATH
set PATH /opt/homebrew/bin $PATH

#
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH  $PYENV_ROOT/bin $PATH
# pyenv init - | source

# disable display time
set -U theme_display_date no
set -U theme_displa_cmd_duration no


bind yy fish_clipboard_copy
bind Y fish_clipboard_copy
bind p fish_clipboard_paste

if status is-interactive
    # Commands to run in interactive sessions can go here
end

#Git
abbr -a g 'git'
abbr -a gb 'git branch'
abbr -a gco 'git commit'
abbr -a gc 'git checkout'
abbr -a ga 'git add'
abbr -a gp 'git push'

#general
abbr -a c 'clear'
abbr -a e 'exit'

#Fish
abbr -a hs 'history search'
abbr -a ths 'thistory search'

#設定ファイルの編集・反映
abbr -a ec nvim ~/.config/fish/config.fish
abbr -a sc source ~/.config/fish/config.fish
abbr -a edot nvim ~/dotfiles/
abbr -a tsc tmux source ~/.tmux.conf
abbr -a reload exit $shell
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/fukazawanatsuki/.lmstudio/bin