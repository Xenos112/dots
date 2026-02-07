return {
  {
    "nvim-lualine/lualine.nvim",
    event = "BufRead",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          component_separators = "",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            {
              function()
                local devicons = require("nvim-web-devicons")
                local filename = vim.fn.expand("%:t")
                local ext = vim.fn.expand("%:e")
                local icon, _ = devicons.get_icon(filename, ext, { default = true })
                return vim.trim((icon .. " " .. filename) or "")
              end,
              separator = { right = "" },
              right_padding = 2,
            },
          },

          lualine_b = {
            "branch",
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              sections = { "error", "warn", "info", "hint" },
              symbols = { error = " ", warn = " ", info = "󰋼 ", hint = " " },
            },
          },
          lualine_c = {
            "%=",
          },
          lualine_x = { { "diff", symbols = { added = " ", modified = " ", removed = " " } } },
          lualine_y = { "location" },
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = { "filename" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "location" },
        },
        tabline = {},
        extensions = {},
      })
    end,
  },
}
