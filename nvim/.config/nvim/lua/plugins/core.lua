return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "python",
          "javascript",
          "typescript",
          "bash",
          "markdown",
          "markdown_inline",
          "json",
          "yaml",
          "toml",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = false },
      })
    end,
  }
}
