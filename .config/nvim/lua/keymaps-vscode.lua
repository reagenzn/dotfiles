-- local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

local opts = {
    noremap = true,
    silent = true
}

keymap("n", "<C-m>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", opts)
keymap("x", "<C-m>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", opts)
keymap("i", "<C-m>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", opts)
keymap("i", "<C-m>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", opts)
keymap("v", "<C-m>", "<Cmd>lua require('vscode-multi-cursor').addSelectionToNextFindMatch()<CR>", opts)

keymap("n", "<space>q", ":qa!<CR>", opts)

keymap('n', 'zc', "<Cmd>lua require('vscode-neovim').call('editor.fold')<CR>", opts)
keymap('n', 'zC', "<Cmd>lua require('vscode-neovim').call('editor.foldRecursively')<CR>", opts)
keymap('n', 'zo', "<Cmd>lua require('vscode-neovim').call('editor.unfold')<CR>", opts)
keymap('n', 'zo', "<Cmd>lua require('vscode-neovim').call('editor.unfold')<CR>", opts)
keymap('n', 'zO', "<Cmd>lua require('vscode-neovim').call('editor.unfoldRecursively')<CR>", opts)
keymap('n', 'za', "<Cmd>lua require('vscode-neovim').call('editor.toggleFold')<CR>", opts)
keymap('n', 'zA', "<Cmd>lua require('vscode-neovim').call('editor.toggleFoldRecursively')<CR>", opts)

keymap('n', '[', "<Cmd>lua require('vscode-neovim').call('editor.action.peekDefinition')<CR>", opts)

-- ESC*2 でハイライトやめる
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)
