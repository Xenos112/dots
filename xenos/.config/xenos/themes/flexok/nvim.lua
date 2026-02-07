return {
  "kepano/flexoki-neovim",
  lazy = false,
  config = function()
    require("flexoki").setup {}
    vim.cmd [[colorscheme flexoki-dark]]
  end
}
