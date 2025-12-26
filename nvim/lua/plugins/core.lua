return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if not status_ok then
        return
      end

      configs.setup({
        auto_install = true,
        ensure_installed = {
          "lua",
          "typescript",
          "javascript",
          "go",
          "c",
          "tsx",
          "jsdoc",
        },
        highlight = {
          enable = true,
          disable = function(_lang, buf)
            local max_filesize = 100 * 1024
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
        textobjects = { enable = false },
        playground = { enable = false },
      })
    end,
  },
}