-- lua/plugins/ui.lua
-- Bufferline
local color_palette = require("catppuccin.palettes").get_palette("frappe")
local bg_highlight = color_palette.crust
local separator_fg = color_palette.crust

require("bufferline").setup({
  highlights = require("catppuccin.special.bufferline").get_theme({
    custom = {
      all = {
        fill = { bg = bg_highlight },
        separator = { fg = separator_fg },
        separator_visible = { fg = separator_fg },
        separator_selected = { fg = separator_fg },
        offset_separator = { fg = separator_fg },
      },
    },
  }),
  options = {
    mode = "buffers",
    separator_style = "slant",
    offsets = {
      {
        filetype = "neo-tree",
        text = "File Explorer",
        highlight = "Directory",
        separator = true,
      },
    },
    diagnostics = "nvim_lsp",
  },
})

-- Lualine
require("lualine").setup({
  options = {
    icons_enabled = true,
  },
  sections = {
    lualine_a = {
      {
        "filename",
        path = 1,
      },
    },
  },
})

-- Noice
require("noice").setup({
  cmdline = { enabled = true },
  messages = { enabled = false },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  views = {
    cmdline_popup = {
      position = { row = "50%", col = "50%" },
      size = { width = 60, height = "auto" },
    },
    popupmenu = {
      relative = "editor",
      position = { row = "61%", col = "50%" },
      size = { width = 60, height = 10 },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
      },
    },
  },
})