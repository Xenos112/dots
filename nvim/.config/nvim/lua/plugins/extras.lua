return {
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<cr>" },
    },
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>tc", "<cmd>TodoTelescope<cr>" },
    },
  },
  {
    "echasnovski/mini.nvim",
    event = "InsertEnter",
    config = function()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.ai").setup()
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "InsertEnter",
    keys = {
      { "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>" },
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>" },
      { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>" },
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>" },
    },
    config = function()
      require("gitsigns").setup({})
    end,
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod',                     lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', lazy = true },
    },
    ft = { 'sql', 'mysql', 'plsql' },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  {
    'vimpostor/vim-tpipeline',
    event = "VeryLazy",
    config = function()
      vim.cmd [[
        set termguicolors
        let g:tpipeline_autoembed = 1
      ]]
    end
  },
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },
}
