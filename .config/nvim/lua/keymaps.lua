local opts = { noremap = true, silent = true }

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap



-- 保存用のコマンド
keymap("n", "<C-s>", ":w<CR>", opts)

-- Moving --
keymap("n", "J", "10j", opts)
keymap("n", "K", "10k", opts)
keymap("n", "H", "0", opts)
keymap("n", "L", "$", opts)

-- ビジュアルモードの選択範囲で検索
keymap('v', '/', "\"fy/\\V<C-R>f<CR>" ,opts)

keymap("v", "J", "10j", opts)
keymap("v", "K", "10k", opts)

-- paste 時にレジスタに入れない
keymap("v", "p", "pgvy", opts)

-- Select all
keymap("n", "<C-a>", "gg<S-v>G", opts)

-- Do not yank with x
keymap("n", "x", '"_x', opts)

-- Delete a word backwards
keymap("n", "dw", 'vb"_d', opts)

-- ;でコマンド入力( ;と:を入れ替)
-- keymap("n", ";", ":", opts)

-- 検索
keymap("n", "<C-f>", "/", opts)

-- redo with U
keymap("n", "U", "<C-r>", opts)

-- 行末までのヤンクにする
keymap("n", "Y", "y$", opts)

-- ESC*2 でハイライトやめる
-- keymap("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)

-- コンマの後に自動的にスペースを挿入
keymap("i", ",", ",<Space>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ビジュアルモード時vで行末まで選択
keymap("v", "v", "$h", opts)
keymap("v", "L", "$h", opts)

-- 0番レジスタを使いやすくした
keymap("v", "<C-p>", '"0p', opts)