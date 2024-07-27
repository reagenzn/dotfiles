require("util")
require("base")
require("autocmds")
require("options")
require('keymaps')
require('lazy_nvim')
if vim.g.vscode == 1 then
  require("keymaps-vscode")
else
  require("keymaps-neovim")
end




-- begin settings
if vim.g.vscode == 1 then
else
  -- dein setting
  local dein_dir = vim.fn.expand('~/.cache/dein')
  local dein_repo_dir = dein_dir .. '/repos/github.com/Shougo/dein.vim'

  vim.o.runtimepath = dein_repo_dir .. ',' .. vim.o.runtimepath

  if (vim.fn.isdirectory(dein_repo_dir) == 0) then
    os.execute('git clone https://github.com/Shougo/dein.vim ' .. dein_repo_dir)
  end
  if (vim.fn['dein#load_state'](dein_dir) == 1) then
    local dir_name = get_os_dir()
    local rc_dir = vim.fn.expand(dir_name)
    local common_toml = rc_dir .. '/dein.toml'
    local neovim_toml = rc_dir .. '/neovim_dein.toml'
    local vscode_toml = rc_dir .. '/vscode_dein.toml'
    vim.fn['dein#begin'](dein_dir)
    vim.fn['dein#load_toml'](common_toml, { lazy = 0 })
    if vim.g.vscode == 1 then
      vim.fn['dein#load_toml'](vscode_toml, { lazy = 0 })
    else
      vim.fn['dein#load_toml'](neovim_toml, { lazy = 0 })
    end

    vim.fn['dein#end']()
    vim.fn['dein#save_state']()
  end

  -- plugin install check
  if (vim.fn['dein#check_install']() ~= 0) then
    vim.fn['dein#install']()
  end

  -- plugin remove check
  local removed_plugins = vim.fn['dein#check_clean']()
  if vim.fn.len(removed_plugins) > 0 then
    vim.fn.map(removed_plugins, "delete(v:val, 'rf')")
    vim.fn['dein#recache_runtimepath']()
  end
end
