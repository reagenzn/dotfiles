require("util")

vim.cmd("autocmd!")

vim.scriptencoding = "utf-8"

vim.wo.number = true

local OS_TYPE = get_os_type()
if OS_TYPE == 'Windows' then
	vim.g.python3_host_prog= 'C:/WINDOWS/py'
else
	-- macOS/Linux の場合、pyenv で管理される Python を使用
	vim.g.python3_host_prog = vim.fn.expand('~/.pyenv/shims/python')
end
