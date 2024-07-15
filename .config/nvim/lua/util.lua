-- os recognize
function get_os_type()
    -- print(vim.fn.has('win32'))
    -- print(vim.fn.has('mac'))

    local is_mac = vim.fn.has('mac') == 1
    local is_window = vim.fn.has('win32') == 1

    if is_mac then
        return 'Mac OS'
    elseif is_window then
        return 'Windows'
    else
        return 'Unix'

    end
end


function get_os_dir()
    local os_type = get_os_type()
    print(os_type)

    local dir_name = ''
    if os_type == 'Mac OS' then
        dir_name = '~/.config/nvim'
    elseif os_type == 'Unix' then
        dir_name = '~/.config/nvim'
    else -- Windows
        dir_name = '~/AppData/Local/nvim'
    end
    return dir_name

end
_G["get_os_type"] = get_os_type
_G["get_os_dir"] = get_os_dir
