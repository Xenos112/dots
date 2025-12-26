return {
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		keys = {
			{ "<leader>e", "<cmd>Oil<CR>" },
		},
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
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
			{ "<leader>ff", "<cmd>Telescope find_files<CR>", { silent = true } },
			{ "<leader>fw", "<cmd>Telescope live_grep<CR>", { silent = true } },
			{ "<leader>fg", "<cmd>Telescope git_files<CR>", { silent = true } },
			{ "<leader>fh", "<cmd>Telescope help_tags<CR>", { silent = true } },
			{ "<leader>fb", "<cmd>Telescope buffers<CR>", { silent = true } },
		},
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>h", ':lua require("harpoon.mark").add_file()<CR>', { silent = true } },
			{ "<leader>H", ':lua require("harpoon.ui").toggle_quick_menu()<CR>', { silent = true } },
		},
	},
}
