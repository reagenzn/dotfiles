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
keymap('n', ']', "<Cmd>lua require('vscode-neovim').call('editor.action.goToTypeDefinition')<CR>", opts)

-- ESC*2 でハイライトやめる
keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- Default oil.code keymaps
local vscode = require('vscode')
local map = vim.keymap.set
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
    pattern = { "*" },
    callback = function()
        map("n", "-", function() vscode.action('oil-code.open') end)
    end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { "oil" },
    callback = function()
        map("n", "-", function() vscode.action('oil-code.openParent') end)
        map("n", "_", function() vscode.action('oil-code.openCwd') end)
        map("n", "<CR>", function() vscode.action('oil-code.select') end)
        map("n", "<C-t>", function() vscode.action('oil-code.selectTab') end)
        map("n", "<C-l>", function() vscode.action('oil-code.refresh') end)
        map("n", "`", function() vscode.action('oil-code.cd') end)
    end,
})
