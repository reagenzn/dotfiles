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

#gwt (git worktree runner)
abbr -a gwn 'git gtr new'
abbr -a gwe 'git gtr editor'
abbr -a gwa 'git gtr ai'
abbr -a gwl 'git gtr list'
abbr -a gwrm 'git gtr rm'
abbr -a gwc 'git gtr clean --merged'

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
abbr -a ta tmux attach -t
abbr -a tl tmux list-sessions
abbr -a spt setup-parralel-tasks

# Added by LM Studio CI (lms)
set -gx PATH $PATH /Users/fukazawanatsuki/.lmstudio/binset -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
# pyenv init - | source. . 
set -gx PATH $PATH /Users/fukazawanatsuki/.lmstudio/bin

# parallel-tasks setup.sh用の設定
abbr -a pt-setup '/Users/fukazawanatsuki/parallel-tasks/setup.sh'

# parallel-tasksディレクトリPATHに追加
set -gx PATH $PATH /Users/fukazawanatsuki/parallel-tasks

# ローカルのbindディレクトリをPATHに追加（シンボリックリンク用）
# set -gx PATH $PATH $HOME/.local/binabbr -a agent-send /Users/fukazawanatsuki/parallel-tasks/agent-send.sh

abbr -a qs 'cd ~/forStudy/Quartz && npx quartz sync'



# Added by Antigravity
fish_add_path /Users/fukazawanatsuki/.antigravity/antigravity/bin
set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
