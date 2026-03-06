return {
    {
        "stevearc/oil.nvim",
        opts = {
            view_options = {
                show_hidden = true,
            },
        },
        keys = {
            { "<leader>e", "<cmd>Oil<CR>" },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        opts = function()
            return {
                defaults = {
                    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                    layout_config = {
                        prompt_position = "bottom",
                        preview_width = 0.0,
                        preview_cutoff = 9999,
                    },
                    previewer = false,
                },
            }
        end,
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", silent = true },
            { "<leader>fw", "<cmd>Telescope live_grep<CR>",  silent = true },
            { "<leader>fg", "<cmd>Telescope git_files<CR>",  silent = true },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>",  silent = true },
            { "<leader>fb", "<cmd>Telescope buffers<CR>",    silent = true },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            {
                "<leader>h",
                function()
                    require("harpoon"):list():add()
                end,
                silent = true,
            },
            {
                "<leader>H",
                function()
                    local harpoon = require("harpoon")
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                silent = true,
            },
        },
    },
}
