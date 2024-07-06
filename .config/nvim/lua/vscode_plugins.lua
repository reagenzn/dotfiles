return {{
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
        -- function _NextFindMatch()
        --     require("vscode-multi-cursor").addSelectionToNextFindMatch()
        -- end

    end
}, {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
}}
