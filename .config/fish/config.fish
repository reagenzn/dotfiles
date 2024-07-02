#view
set -g theme_display_date yes
set -g theme_date_format "+%F %H:%M"
set -g theme_display_git_default_branch yes
set -g theme_color_scheme dark

#path
set -x PATH $HOME/.nodebrew/current/bin $PATH
#
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH  $PYENV_ROOT/bin $PATH
# pyenv init - | source

#peco setting
set fish_plugins theme peco

function fish_user_key_bindings
  bind \cw peco_select_history
end


if status is-interactive
    # Commands to run in interactive sessions can go here
end

# vi mode 有効化
for mode in default insert visual
    fish_default_key_bindings -M $mode
end
fish_vi_key_bindings --no-erase
set -g fish_escape_delay_ms 100
bind -M insert -m default jj cancel repaint-mode
set -g fish_sequence_key_delay_ms 200

#abbr -a

#Git
abbr -a g 'git'
abbr -a gb 'git branch'
abbr -a gco 'git commit'
abbr -a gc 'git checkout'
abbr -a ga 'git add'
abbr -a gp 'git push'

#general
abbr -a c 'clear'

#Fish

abbr -a hs 'history search'
abbr -a ths 'thistory search'

#設定ファイルの編集・反映
abbr -a vc nvim ~/.config/fish/config.fish
abbr -a sc source ~/.config/fish/config.fish
abbr -a edot nvim ~/dotfiles/
abbr -a reload exit

