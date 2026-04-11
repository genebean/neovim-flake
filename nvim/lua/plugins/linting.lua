-- lua/plugins/linting.lua
-- nvim-lint replaces none-ls diagnostic sources.
-- All linters are installed by Nix via extraPackages.

local lint = require("lint")

lint.linters["puppet-lint"] = {
  cmd = "puppet-lint",
  args = { "{{filepath}}" },
  stdin = false,
  ignore_exitcode = true,
}

lint.linters_by_ft = {
  puppet = { "puppet-lint" },
  ruby   = { "rubocop" },
  python = { "ruff" },
}

-- Run linters on save and when leaving insert mode
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
  callback = function()
    lint.try_lint()
  end,
})
