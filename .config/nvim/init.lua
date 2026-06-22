require("util")
require("base")
require("autocmds")
require("options")
require('keymaps')
require('lazy_nvim')
if vim.g.vscode == 1 then
    require("keymaps-vscode")
    -- VSCode側がハイライトを描画するため、nvim 0.12 がデフォルト有効化する
    -- built-in treesitter highlight を停止する（エラー源にもなる）
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("vscode_no_treesitter", { clear = true }),
        callback = function(ev)
            -- runtime ftplugin の vim.treesitter.start() より後に実行するため schedule する
            vim.schedule(function()
                if vim.api.nvim_buf_is_valid(ev.buf) then
                    pcall(vim.treesitter.stop, ev.buf)
                end
            end)
        end,
    })
else
  require("keymaps-neovim")
end