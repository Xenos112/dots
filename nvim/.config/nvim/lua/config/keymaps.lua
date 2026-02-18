local map = vim.keymap.set

map("i", "jk", "<ESC>")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

map("n", "<tab>", ":bn<CR>", { silent = true })
map("n", "<S-tab>", ":bp<CR>", { silent = true })

map("n", "<leader>x", ":bd<CR>", { silent = true })
map("v", "<S-j>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<S-k>", ":m '<-2<CR>gv=gv", { silent = true })

