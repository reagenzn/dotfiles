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