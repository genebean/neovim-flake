-- lua/plugins/treesitter.lua
-- Treesitter grammars are pre-built by Nix via withPlugins.
-- Neovim 0.10+ auto-discovers parsers from runtimepath.

-- Start treesitter when puppet files open
vim.api.nvim_create_autocmd("FileType", {
  pattern = "puppet",
  callback = function(args)
    vim.treesitter.start(args.buf)
  end,
})