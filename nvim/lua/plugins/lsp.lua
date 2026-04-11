-- lua/plugins/lsp.lua
-- All LSP servers are installed by Nix via extraPackages.
-- No Mason, no mason-lspconfig.
-- Uses vim.lsp.config (Neovim 0.11+) instead of deprecated require("lspconfig")

local nixInfo = require(vim.g.nix_info_plugin_name)

local on_attach = function(_, bufnr)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr })
  vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { buffer = bufnr })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
end

local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("lemminx", {
  on_attach = on_attach,
  capabilities = capabilities,
})
vim.lsp.enable("lemminx")

vim.lsp.config("lua_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})
vim.lsp.enable("lua_ls")

vim.lsp.config("nil_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["nil"] = {
      nix = {
        flake = {
          autoArchive = true,
        },
      },
    },
  },
})
vim.lsp.enable("nil_ls")

vim.lsp.config("ruff", {
  on_attach = on_attach,
  capabilities = capabilities,
})
vim.lsp.enable("ruff")

local puppet_ls = nixInfo(nil, "puppet_ls")
if puppet_ls then
  vim.lsp.config("puppet", {
    cmd = { puppet_ls, "--feature-flags=puppetstrings" },
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      puppet = {
        editorServices = {
          formatOnType = { enable = true },
        },
      },
    },
  })
  vim.lsp.enable("puppet")
end