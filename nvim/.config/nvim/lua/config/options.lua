vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true

vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#3d59a1", fg = "#191724" })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			higroup = "YankHighlight",
			timeout = 200,
		})
	end,
})

-- remove the ~ symbol in the lines
vim.opt.fillchars:append({ eob = " " })

vim.o.signcolumn = "yes"
vim.o.numberwidth = 2

-- Add this to your lua/config/lsp.lua or init.lua
vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- You can use any icon here
		symbols = {
			error = "", -- nerd-font icon
			warn = "",
			info = "",
			hint = "",
		},
	},
	signs = true, -- Show gutter signs
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})

-- Define custom gutter signs (requires nerd-font installed)
local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
