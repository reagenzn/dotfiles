-- local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap
-- keymap("n", "<C-d>", "<Cmd>lua require('vscode-neovim').call('editor.action.formatSelection')<CR>", opts)
keymap("n", "<C-d>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", {
    noremap = true,
    silent = true
})
keymap("x", "<C-d>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", {
    noremap = true,
    silent = true
})
keymap("i", "<C-d>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", {
    noremap = true,
    silent = true
})
keymap("v", "<C-d>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", {
    noremap = true,
    silent = true
})

keymap("n", "<space>q", ":qa!<CR>", {
    noremap = true,
    silent = true
})

vim.cmd[[nnoremap <silent> [ <cmd>lua require('vscode-neovim').call('editor.action.peekDefinition')<cr>]]
