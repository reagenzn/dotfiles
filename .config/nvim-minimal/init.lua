-- Neovim 最小構成
-- ===========================
-- 基本設定
-- ===========================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- オプション設定
local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  number = true,
  relativenumber = false,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  smartindent = true,
  clipboard = "unnamedplus",
  ignorecase = true,
  smartcase = true,
  hlsearch = true,
  termguicolors = true,
  signcolumn = "yes",
  updatetime = 300,
  timeoutlen = 400,
  completeopt = { "menu", "menuone", "noselect" },
  swapfile = false,
  backup = false,
  undofile = true,
  splitbelow = true,
  splitright = true,
  cursorline = true,
  scrolloff = 8,
  sidescrolloff = 8,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- ===========================
-- lazy.nvim のセットアップ
-- ===========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===========================
-- プラグイン設定
-- ===========================
require("lazy").setup({
  -- LSP関連
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "tsserver",
          "pyright",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSP servers 設定
      local servers = { "lua_ls", "tsserver", "pyright" }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end

      -- LSP キーマップ
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "[", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<Space>t", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<Space>r", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<Space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<Space>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        end,
      })
    end,
  },

  -- 補完
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",

  -- GitHub Copilot
  {
    "github/copilot.vim",
    lazy = false,
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.keymap.set("i", "<Tab>", 'copilot#Accept("<CR>")', {
        silent = true,
        expr = true,
        script = true,
        replace_keycodes = false,
      })
      vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)")
      vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)")
      vim.keymap.set("i", "<C-\\>", "<Plug>(copilot-dismiss)")
    end,
  },

  -- treesitter (シンタックスハイライト強化)
  {
    "nvim-treesitter/nvim-treesitter",
    cond = vim.g.vscode ~= 1,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "javascript", "typescript", "python" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- カラースキーム
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
})

-- ===========================
-- キーマップ設定
-- ===========================
local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- 保存
keymap("n", "<C-s>", ":w<CR>", opts)

-- 移動の高速化
keymap("n", "J", "10j", opts)
keymap("n", "K", "10k", opts)
keymap("n", "H", "0", opts)
keymap("n", "L", "$", opts)

-- ビジュアルモード
keymap("v", "J", "10j", opts)
keymap("v", "K", "10k", opts)
keymap("v", "L", "$h", opts)

-- インデント調整
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ペースト時にレジスタに入れない
keymap("v", "p", "pgvy", opts)

-- 全選択
keymap("n", "<C-a>", "gg<S-v>G", opts)

-- x で削除時にレジスタに入れない
keymap("n", "x", '"_x', opts)

-- 単語削除
keymap("n", "dw", 'vb"_d', opts)

-- 検索
keymap("n", "<C-f>", "/", opts)

-- Redo
keymap("n", "U", "<C-r>", opts)

-- 行末までヤンク
keymap("n", "Y", "y$", opts)

-- Insert mode
keymap("i", "jj", "<ESC>", opts)
keymap("i", "jk", "<ESC>", opts)
keymap("i", ",", ", ", opts)

-- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- タブ移動
keymap("n", "gh", "gT", opts)
keymap("n", "gl", "gt", opts)
keymap("n", "gn", ":tabnew<CR>", opts)

-- 分割
keymap("n", "ss", ":split<CR>", opts)
keymap("n", "sv", ":vsplit<CR>", opts)

-- コマンドモード
keymap("n", ";", ":", opts)

-- 強制終了
keymap("n", "<Space>q", ":q!<CR>", opts)

-- 0番レジスタ
keymap("v", "<C-p>", '"0p', opts)
