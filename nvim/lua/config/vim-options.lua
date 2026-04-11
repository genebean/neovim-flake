-- lua/config/vim-options.lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- make sure vim knows I always have a dark terminal
vim.opt.background = "dark"

-- use spaces for tabs and whatnot
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true

-- make sure all the mouse stuff is on.
vim.opt.mouse = "a"

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

vim.wo.number = true
vim.o.termguicolors = true

-- global statusline (works better without edgy)
vim.opt.laststatus = 3
vim.opt.splitkeep = "screen"
