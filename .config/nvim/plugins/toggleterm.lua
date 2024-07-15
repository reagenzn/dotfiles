
local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ cmd = "lazygit", direction = "float",  hidden = true })
function _Lazygit_toggle()
     lazygit:toggle()
 end

vim.keymap.set("n", "<leader>gs", "<cmd>lua _Lazygit_toggle()<CR>", {noremap = true, silent = true})
vim.keymap.set("n", "<leader><Enter>", "<cmd>ToggleTerm<CR>", {noremap = true, silent = true})
vim.keymap.set("t", "<leader><Enter>", "<cmd>ToggleTerm<CR>", {noremap = true, silent = true})
