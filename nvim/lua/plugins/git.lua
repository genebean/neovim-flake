-- lua/plugins/git.lua

-- Gitsigns
require("gitsigns").setup({
  current_line_blame = true,
})
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})

-- LazyGit
require("telescope").load_extension("lazygit")
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
