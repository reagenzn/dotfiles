return {{
  'nvim-lualine/lualine.nvim',
  cond = vim.g.vscode ~= 1,
  config = function()
      require('lualine').setup()
  end
}, {
  'akinsho/toggleterm.nvim',
  version = "*",
  cond = vim.g.vscode ~= 1,
  config = true
}, {
  'lewis6991/gitsigns.nvim',
  cond = vim.g.vscode ~= 1,
  config = function()
      require('gitsigns').setup()
  end
}, {
  "craftzdog/solarized-osaka.nvim",
  cond = vim.g.vscode ~= 1
}, {
  "lambdalisue/fern-git-status.vim",
  cond = vim.g.vscode ~= 1
}, {
  "tpope/vim-surround",
  cond = vim.g.vscode ~= 1
}, {
  "hrsh7th/nvim-cmp",
  cond = vim.g.vscode ~= 1,
  dependencies = {"hrsh7th/cmp-buffer", "hrsh7th/cmp-nvim-lsp", 'quangnguyen30192/cmp-nvim-ultisnips',
                  'hrsh7th/cmp-nvim-lua', 'octaltree/cmp-look', 'hrsh7th/cmp-path', 'hrsh7th/cmp-calc',
                  'f3fora/cmp-spell', 'hrsh7th/cmp-emoji'}
}, {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {{'neovim/nvim-lspconfig'}, {"williamboman/mason.nvim"}},
  cond = vim.g.vscode ~= 1,
  config = function()
      require("mason").setup()
      local registry = require "mason-registry"
      local packages = {"typescript-language-server"}
      registry.refresh(function()
          for _, pkg_name in ipairs(packages) do
              local pkg = registry.get_package(pkg_name)
              if not pkg:is_installed() then
                  pkg:install()
              end
          end
      end)

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require('lspconfig')

      local servers = {"tsserver"}

      for _, lsp in ipairs(servers) do
          lspconfig[lsp].setup {
              -- on_attach = my_custom_on_attach,
              capabilities = capabilities
          }
      end

      -- nvim-cmp key bindings
      local cmp = require("cmp")
      cmp.setup {
          mapping = cmp.mapping.preset.insert({
              ['<F5>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm {
                  behavior = cmp.ConfirmBehavior.Replace,
                  select = true
              },
              ['<C-p>'] = cmp.mapping.abort()
          }),
          sources = {{
              name = 'nvim_lsp'
          }}
      }

      vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
              -- Enable completion triggered by <c-x><c-o>
              vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

              local opts = {
                  buffer = ev.buf
              }
              -- 定義に移動
              vim.keymap.set('n', '[', vim.lsp.buf.definition, opts)
              -- 定義をホバー
              vim.keymap.set('n', '<Space>t', vim.lsp.buf.hover, opts)
              -- 実装へ移動
              vim.keymap.set('n', '<C-j>i', vim.lsp.buf.implementation, opts)
              -- 関数の引数表示
              vim.keymap.set({'n', 'i'}, '<C-p>', vim.lsp.buf.signature_help, opts)
              -- リネーム
              vim.keymap.set({'n', 'i'}, '<S-M-r>', vim.lsp.buf.rename, opts)
              -- Code action (TODO: 楽にしたい)
              vim.keymap.set({'n', 'i'}, '<M-CR>', vim.lsp.buf.code_action, opts)
              -- 呼び出し元一覧 (qflist)
              vim.keymap.set('n', '<C-j>h', vim.lsp.buf.references, opts)
              -- 次の診断へ移動
              vim.keymap.set('n', '<M-j>', vim.diagnostic.goto_next, opts)
              -- 前の診断へ移動
              vim.keymap.set('n', '<M-k>', vim.diagnostic.goto_prev, opts)
              -- TODO: 一旦このまま
              vim.keymap.set('n', '<space>f', function()
                  vim.lsp.buf.format {
                      async = true
                  }
              end, opts)
          end
      })
  end
}, {
  "nvimtools/none-ls.nvim",
  cond = vim.g.vscode ~= 1,
  config = function()
      local null_ls = require("null-ls")
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      null_ls.setup({
          sources = {null_ls.builtins.formatting.prettier},
          on_attach = function(client, bufnr)
              if client.supports_method("textDocument/formatting") then
                  vim.api.nvim_clear_autocmds({
                      group = augroup,
                      buffer = bufnr
                  })
                  vim.api.nvim_create_autocmd("BufWritePre", {
                      group = augroup,
                      buffer = bufnr,
                      callback = function()
                          vim.lsp.buf.format({
                              async = false
                          })
                      end
                  })
              end
          end
      })
  end
}, {
  'nvimdev/lspsaga.nvim',
  cond = vim.g.vscode ~= 1,
  lazy = false,
  init = function()
      local opts = {
          noremap = true,
          silent = true
      }
      vim.keymap.set('n', '[', "<cmd>Lspsaga peek_definition<CR>", opts)
      vim.keymap.set({'n', 'i'}, '<leader>t', "<cmd>Lspsaga code_action<CR>", opts)
      vim.keymap.set('n', '<C-j>', "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
      vim.keymap.set('n', '<C-k>', "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
  end,
  config = function()
      require('lspsaga').setup({
          code_action = {
              extend_gitsigns = true
          }
      })
  end,
  dependencies = {'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons'}
}, {
  "airblade/vim-gitgutter",
  cond = vim.g.vscode ~= 1,
  lazy = false,
  init = function()
      vim.signcolumn = "yes"
      vim.g.gitgutter_async = 1
      vim.g.gitgutter_sign_modified = "%"
      vim.g.gitgutter_map_keys = 0
  end,
  keys = {{
      "]c",
      "<Plug>(GitGutterNextHunk)",
      mode = {"n"},
      silent = true
  }, {
      "[c",
      "<Plug>(GitGutterPrevHunk)",
      mode = {"n"},
      silent = true
  }}
}, {
  "lambdalisue/fern.vim",
  cond = vim.g.vscode ~= 1,
  init = function()
      vim.g["fern#default_hidden"] = 1
      vim.g["fern#loglevel"] = "info"
  end
}, {
  "cespare/vim-toml",
  cond = vim.g.vscode ~= 1
}, {
  "lambdalisue/nerdfont.vim",
  cond = vim.g.vscode ~= 1
}, {
  "vim-jp/vimdoc-ja",
  cond = vim.g.vscode ~= 1
}, {
  "nvim-telescope/telescope.nvim",
  version = "*",
  cond = vim.g.vscode ~= 1,
  lazy = false,
  keys = {{
      "<Space>p",
      "<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git <cr>",
      mode = {"n"},
      silent = true
  }, {"<Space>hh", "<cmd>Telescope live_grep<cr>"}, {"<Space>hb", "<cmd>Telescope buffers<cr>"},
          {"<Space>;;", "<cmd>Telescope resume<cr>"}, {"<Space>fl", "<cmd>Telescope lazy<cr>"}},
  dependencies = {'nvim-lua/plenary.nvim'},
  config = function()
      local actions = require("telescope.actions")
      require("telescope").setup {
          defaults = {
              mappings = {
                  i = {
                      ["<esc>"] = actions.close,
                      ["<F12>"] = actions.select_vertical
                  },
                  n = {
                      ["q"] = actions.close
                  }
              },
              layout_strategy = 'vertical'
          },
          extensions = {
              frecency = {
                  show_scores = true
              }
          }
      }
  end
}, {
  "lambdalisue/gina.vim",
  lazy = false,
  cond = vim.g.vscode ~= 1,
  keys = {{
      "<Space>'",
      "<cmd>Gina status<cr>",
      mode = {"n"},
      silent = true
  }}
}, {
  "github/copilot.vim",
  cond = vim.g.vscode ~= 1,
  lazy = false,
  keys = {{
      "<leader>[",
      "<cmd>lua require('copilot').run()<cr>",
      desc = "Copilot"
  }},
  config = function()
      vim.g.copilot_no_tab_map = true

      local keymap = vim.keymap.set
      keymap("i", "<Tab>", 'copilot#Accept("<CR>")', {
          silent = true,
          expr = true,
          script = true,
          replace_keycodes = false
      })
      keymap("i", "<C-j>", "<Plug>(copilot-next)")
      keymap("i", "<C-k>", "<Plug>(copilot-previous)")
      keymap("i", "<C-o>", "<Plug>(copilot-dismiss)")
      keymap("i", "<C-s>", "<Plug>(copilot-suggest)")
  end
}, {
  "kdheepak/lazygit.nvim",
  lazy = false,
  cond = vim.g.vscode ~= 1,
  keys = {{
      "<Space>gg",
      "<cmd>LazyGit<cr>",
      desc = "LazyGit"
  }}
}, {
  "akinsho/toggleterm.nvim",
  cond = vim.g.vscode ~= 1,

  lazy = false,
  keys = { -- <S-CR> は Shift + Enter の意味だが、cui版のvimでしか動かない
  {
      "<Space><enter>",
      "<cmd>ToggleTerm<cr>",
      desc = "ToggleTerm"
  }}
}, {
  "luochen1990/rainbow",
  cond = vim.g.vscode ~= 1,
  init = function()
      vim.g.rainbow_active = 1
  end
}, {
  "folke/flash.nvim",
  event = "VeryLazy",
  cond = vim.g.vscode ~= 1,
  opts = {},
  keys = {{
      "s",
      mode = {"n", "x", "o"},
      function()
          require("flash").jump()
      end,
      desc = "Flash"
  }, {
      "S",
      mode = {"n", "x", "o"},
      function()
          require("flash").treesitter()
      end,
      desc = "Flash Treesitter"
  }, {
      "r",
      mode = "o",
      function()
          require("flash").remote()
      end,
      desc = "Remote Flash"
  }, {
      "R",
      mode = {"o", "x"},
      function()
          require("flash").treesitter_search()
      end,
      desc = "Treesitter Search"
  }, {
      "<c-s>",
      mode = {"c"},
      function()
          require("flash").toggle()
      end,
      desc = "Toggle Flash Search"
  }}
}, {
  "nvim-treesitter/nvim-treesitter",
  cond = vim.g.vscode ~= 1,
  ensure_installed = 'maintained',
  highlight = {
      enable = true
  }
}, {
  "alvan/vim-closetag",
  cond = vim.g.vscode ~= 1,
  init = function()
      vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.php,*.jsx,*.tsx,*.js,*.ts,*.xml"
      vim.g.closetag_xhtml_filenames = '*.jsx,*.tsx,*.vue'
      vim.g.closetag_filetypes = 'html'
      vim.g.closetag_xhtml_filetypes = 'jsx,tsx,javascript.jsx,typescript.tsx,vue'
      vim.g.closetag_emptyTags_caseSensitive = 1
      vim.g.closetag_shortcut = '>'
  end
}, {
  'numToStr/Comment.nvim',
  cond = vim.g.vscode ~= 1,
  opts = {}
}, {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  cond = vim.g.vscode ~= 1,
  opts = {
      bind = true,
      handler_opts = {
          border = "rounded"
      }
  },
  config = function(_, opts)
      require'lsp_signature'.setup(opts)
  end
},
-- for vscode
{
  'vscode-neovim/vscode-multi-cursor.nvim',
  version = "*",
  event = 'VeryLazy',
  cond = vim.g.vscode == 1,
  opts = {},
  config = function()
      require('vscode-multi-cursor').setup { -- Config is optional
          -- Whether to set default mappings
          default_mappings = true,
          -- If set to true, only multiple cursors will be created without multiple selections
          no_selection = false
      }
  end
}, {
  "kylechui/nvim-surround",
  version = "*", -- use for stability; omit to use `main` branch for the latest features
  cond = vim.g.vscode == 1,
  event = "VeryLazy",
  config = function()
      require("nvim-surround").setup({
          -- configuration here, or leave empty to use defaults
      })
  end
}, {
  "nvim-treesitter/nvim-treesitter",
  ensure_installed = 'maintained',
  highlight = {
      enable = true
  }
}, {
  "folke/flash.nvim",
  event = "VeryLazy",
  cond = vim.g.vscode == 1,
  -- configuration options for flash plugin
  opts = {
      modes = {
          char = {
              label = {
                  exclude = "hjkliardcf"
              },
              keys = {"t", "T", ";", ","}
          }
      }
  },
  -- stylua: ignore
  keys = {{
      "F",
      mode = {"n", "x", "o"},
      function()
          require("flash").treesitter()
      end,
      desc = "Flash Treesitter"
  }, {
      "f",
      mode = "n",
      function()
          require("flash").remote()
      end,
      desc = "Remote Flash"
  }, {
      "R",
      mode = {"n", "x", "o"},
      function()
          require("flash").treesitter_search()
      end,
      desc = "Treesitter Search"
  }, {
      "Q",
      mode = {"n"},
      function()
          require("flash").toggle()
      end,
      desc = "Toggle Flash Search"
  }}
}}
