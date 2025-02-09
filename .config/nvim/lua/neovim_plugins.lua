return { {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup()
  end
}, {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = true
}, {
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup()
  end
},
  {
    "craftzdog/solarized-osaka.nvim",
  },
  {
    "lambdalisue/fern-git-status.vim",
  },
  {
    "tpope/vim-surround",
  },
  {
    'easymotion/vim-easymotion',
    lazy = false,
    keys = {
      { "<Space>f", "<Plug>(easymotion-bd-f)", mode = { "n" }, silent = true },
    },
    init = function()
      vim.g.EasyMotion_smartcase = 1
    end,
  },
  {
    "tomtom/tcomment_vim",
    key = {
      { "<Space>c", "<Plug>TComment", mode = { "n", "v" }, silent = true },
    }
  },
  {
    "airblade/vim-gitgutter",
    lazy = false,
    init = function()
      vim.signcolumn = "yes"
      vim.g.gitgutter_async = 1
      vim.g.gitgutter_sign_modified = "%"
      vim.g.gitgutter_map_keys = 0
    end,
    keys = {
      { "]c", "<Plug>(GitGutterNextHunk)", mode = { "n" }, silent = true },
      { "[c", "<Plug>(GitGutterPrevHunk)", mode = { "n" }, silent = true },
    }
  },
  {
    "lambdalisue/fern.vim",
    init = function()
      vim.g["fern#default_hidden"] = 1
      vim.g["fern#loglevel"] = "info"
    end,
  },
  {
    "cespare/vim-toml"
  },
  {
    "lambdalisue/nerdfont.vim"
  },
  {
    "vim-jp/vimdoc-ja"
  },
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    lazy = false,
    keys = {
      { "<Space>p",  "<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git <cr>", mode = { "n" }, silent = true },
      { "<Space>hh", "<cmd>Telescope live_grep<cr>", },
      { "<Space>hb", "<cmd>Telescope buffers<cr>", },
      { "<Space>;;", "<cmd>Telescope resume<cr>", },
      { "<Space>fl", "<cmd>Telescope lazy<cr>", },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup {
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<F12>"] = actions.select_vertical,
            },
            n = { ["q"] = actions.close },
          },
          layout_strategy = 'vertical'
        },
        extensions = {
          frecency = {
            show_scores = true
          }
        }
      }
    end,
  },
  {
    "lambdalisue/gina.vim",
    lazy = false,
    keys = { { "<leader>'", "<cmd>Gina status<cr>", mode = { "n" }, silent = true } }
  },
  {
    "github/copilot.vim",
    lazy = false,
    keys = {
      { "<leader>[", "<cmd>lua require('copilot').run()<cr>", desc = "Copilot" },
    },
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = false,
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    lazy = false,
    keys = {
      { "<leader><Enter>", "<cmd>ToggleTerm<cr>", desc = "ToggleTerm" },
    },
  },
  {
    "luochen1990/rainbow",
    init = function()
      vim.g.rainbow_active = 1
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    ensure_installed = 'maintained',
    highlight = {
      enable = true,
    },
  }, {
  "alvan/vim-closetag",
  init = function()
    vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.php,*.jsx,*.tsx,*.js,*.ts,*.xml"
    vim.g.closetag_xhtml_filenames = '*.jsx,*.tsx,*.vue'
    vim.g.closetag_filetypes = 'html'
    vim.g.closetag_xhtml_filetypes = 'jsx,tsx,javascript.jsx,typescript.tsx,vue'
    vim.g.closetag_emptyTags_caseSensitive = 1
    vim.g.closetag_shortcut = '>'
  end,
}
}
