return {
    {
        'vscode-neovim/vscode-multi-cursor.nvim',
        version = "*",
        event = 'VeryLazy',
        opts = {},
        config = function()
            require('vscode-multi-cursor').setup { -- Config is optional
                -- Whether to set default mappings
                default_mappings = true,
                -- If set to true, only multiple cursors will be created without multiple selections
                no_selection = false
            }
        end
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- use for stability; omit to use `main` branch for the latest features
        event = "verylazy",
        config = function()
            require("nvim-surround").setup({
                -- configuration here, or leave empty to use defaults
            })
        end
    },
    {
        "folke/flash.nvim",
        event = "verylazy",
        -- configuration options for flash plugin
        opts = {
            modes = {
                char = {
                    label = { exclude = "hjkliardcf"},
                    keys = { "t", "T", ";", ","}
                }
            }
        },
        -- stylua: ignore
        keys = {
            { "F",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "f",     mode = "n",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "n", "x", "o" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "G", mode = { "n" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },
}
