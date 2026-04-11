-- lua/plugins/catppuccin.lua
-- Catppuccin 2.0.0: flavour -> variant
require("catppuccin").setup({
  variant = "frappe",
  transparent_background = true,
  color_overrides = {
    frappe = {
      base = "#07042B",
      mantle = "#0c0746",
      crust = "#10095d",
      rosewater = "#FF7F7F",
    },
  },
  custom_highlights = function(colors)
    return {
      Comment = { fg = colors.subtext0 },
      LineNr = { fg = colors.subtext0 },
    }
  end,
})
vim.cmd.colorscheme("catppuccin")
vim.opt.fillchars:append({ eob = " " })