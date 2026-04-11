-- init.lua
-- The nix-wrapper-modules wrapper handles plugin loading.
-- This file just sets up options and enables the lua bytecode cache.

vim.loader.enable()

require("config.vim-options")
require("plugins.alpha")
require("plugins.catppuccin")
require("plugins.completion")
require("plugins.formatting")
require("plugins.git")
require("plugins.linting")
require("plugins.lsp")
require("plugins.nav")
require("plugins.terminal")
require("plugins.treesitter")
require("plugins.ui")
