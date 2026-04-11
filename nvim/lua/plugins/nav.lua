-- lua/plugins/nav.lua

-- Neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", {})
require("neo-tree").setup({
  filesystem = {
    follow_current_file = { enabled = true },
    hijack_netrw_behavior = "open_default",
  },
  follow_current_file = { enabled = true },
})

-- Telescope
require("telescope").setup({
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({}),
    },
  },
})
require("telescope").load_extension("ui-select")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ts", ":Telescope<CR>")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- Todo comments
require("todo-comments").setup({})

-- Which-key
require("which-key").setup({})

-- Trouble
require("trouble").setup({})
