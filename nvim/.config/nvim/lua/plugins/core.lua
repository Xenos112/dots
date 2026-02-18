return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        event = { "VeryLazy", "BufReadPost", "BufNewFile" },
        config = function()
            require 'nvim-treesitter'.setup {
                install_dir = vim.fn.stdpath('data') .. '/site'
            }

            require 'nvim-treesitter'.install { 'typecript', 'javascript', 'python', 'go', 'lua', 'css', 'html', 'tsx' }
        end,
    },
}
