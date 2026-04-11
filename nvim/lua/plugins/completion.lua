-- lua/plugins/completion.lua
-- blink.cmp replaces nvim-cmp + cmp-nvim-lsp + LuaSnip.
-- friendly-snippets is loaded automatically by blink's snippet source.

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    -- Keep familiar nvim-cmp-ish bindings
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { border = "rounded" },
    },
    menu = {
      border = "rounded",
      -- Filter out Text kind completions from LSP (same as your old cmp config)
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
      },
    },
    -- Don't auto-select, require explicit confirmation (matches your old CR behavior)
    list = { selection = { preselect = true, auto_insert = true } },
  },
  snippets = { preset = "default" },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
