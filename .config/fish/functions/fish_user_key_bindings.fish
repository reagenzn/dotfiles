
function fish_user_key_bindings
    bind \cw peco_select_history
    # vi mode 有効化
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
    set -g fish_escape_delay_ms 100
    bind -M insert -m default jj cancel repaint-mode
    set -g fish_sequence_key_delay_ms 200
end
