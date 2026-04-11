-- lua/plugins/formatting.lua
-- conform.nvim replaces none-ls formatting sources.
-- All formatters are installed by Nix via extraPackages.

require("conform").setup({
  formatters_by_ft = {
    css        = { "prettier" },
    html       = { "prettier" },
    javascript = { "prettier" },
    json       = { "prettier" },
    lua        = { "stylua" },
    markdown   = { "prettier" },
    puppet     = { "puppet-lint" },
    ruby       = { "rubocop" },
    typescript = { "prettier" },
    yaml       = { "prettier" },
  },
  format_on_save = nil, -- set to { timeout_ms = 500, lsp_fallback = true } to enable
})

vim.keymap.set("n", "<leader>gf", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })
