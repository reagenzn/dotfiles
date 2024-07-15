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
    lazy = false,
    priority = 1000,
    opts = {},
  } }

--   {
-- 'nvim-lualine/lualine.nvim',
--   dependencies = { 'nvim-tree/nvim-web-devicons' },
--   config = function()
--     require('lualine').setup()
--   end
-- },
-- {'akinsho/toggleterm.nvim', version = "*", config = true}
