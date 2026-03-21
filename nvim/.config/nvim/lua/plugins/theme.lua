return {
  "rose-pine/neovim",
  lazy = false,
  config = function()
    require("rose-pine").setup {}
    vim.cmd [[colorscheme rose-pine]]
  end
}
