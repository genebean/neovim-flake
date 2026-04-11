# genebean's Neovim Flake

A standalone Neovim configuration managed entirely by Nix via
[nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).
No lazy.nvim, no Mason — plugins and LSP servers come from the Nix store.

## Requirements

- Neovim 0.12+ (tested with 0.12.1)
- Nix 24.11+ with flakes enabled
- catppuccin-nvim 2.0.0+
- nvim-lspconfig 2.7.0+

## Structure

```
flake.nix                        # main flake: inputs, packages, HM module
hm-module.nix                    # home-manager module for use in dots
DOTS-INTEGRATION.nix             # notes on wiring into genebean/dots
nvim/
  init.lua                       # entry point (minimal: options + loader)
  lua/
    config/
      vim-options.lua            # keymaps, editor options
    plugins/
      alpha.lua                  # dashboard
      catppuccin.lua             # theme (loads first)
      completion.lua             # blink.cmp
      formatting.lua             # conform.nvim
      git.lua                    # gitsigns, fugitive, lazygit
      linting.lua                # nvim-lint
      lsp.lua                    # vim.lsp.config API (Neovim 0.11+)
      nav.lua                    # neo-tree, telescope, todo, which-key, trouble
      terminal.lua               # toggleterm, vim-tmux-navigator
      treesitter.lua             # Neovim 0.10+ built-in treesitter
      ui.lua                     # bufferline, lualine, noice
pkgs/
  puppet-editor-services/
    default.nix                  # bundlerApp derivation
    Gemfile                      # gem source
    Gemfile.lock                 # MUST GENERATE — see Bootstrap below
    gemset.nix                   # MUST GENERATE — see Bootstrap below
```

## Bootstrap (one-time setup)

Before the flake will build, you need to generate the bundix lockfiles
for puppet-editor-services:

```bash
cd pkgs/puppet-editor-services

# Enter a shell with bundix and ruby available
nix shell nixpkgs#bundix nixpkgs#ruby

# Generate Gemfile.lock
bundle lock

# Generate gemset.nix
bundix

exit
```

Commit both `Gemfile.lock` and `gemset.nix`.

## Usage

```bash
# Run directly (no install)
nix run github:genebean/neovim-flake

# Install to profile
nix profile add github:genebean/neovim-flake

# Build and inspect locally
nix build .
./result/bin/nvim
```

## Integration with genebean/dots

Add to `dots/flake.nix` inputs:

```nix
genebean-neovim = {
  url = "github:genebean/neovim-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Import the HM module and enable it:

```nix
# in your home-manager imports
inputs.genebean-neovim.homeManagerModules.default

# in general/default.nix (or equivalent)
programs.genebean-neovim.enable = true;
```

See `DOTS-INTEGRATION.nix` for the full diff of what to remove from
`general/default.nix`.

## Updating

```bash
# Update all flake inputs (nixpkgs, nix-wrapper-modules)
nix flake update

# Update only nixpkgs
nix flake update nixpkgs

# Update puppet-editor-services gem to latest
cd pkgs/puppet-editor-services
nix shell nixpkgs#bundix nixpkgs#ruby -c bundle update
nix shell nixpkgs#bundix -c bundix
# then commit Gemfile.lock and gemset.nix
```

## Live-edit mode (rapid Lua iteration)

During active development of Lua configs, you can switch to live-edit mode
so changes take effect without a rebuild:

In `flake.nix`, change:
```nix
settings.config_directory = ./nvim;
```
to:
```nix
settings.config_directory = lib.generators.mkLuaInline
  "vim.fn.stdpath('config')";
```

Then run one rebuild. After that, edits under `~/.config/nvim/` take
effect immediately. Switch back and rebuild to lock changes into the store.

## Replacing Mason

All LSP servers and tools that Mason previously managed are now in
`extraPackages` in `flake.nix`:

| Mason package          | Nix package                   |
|------------------------|-------------------------------|
| lemminx                | pkgs.lemminx                  |
| lua-language-server    | pkgs.lua-language-server      |
| nil_ls                 | pkgs.nil                      |
| puppet LSP             | pkgs.puppet-editor-services   |
| ruff                   | pkgs.ruff                     |
| prettier               | pkgs.nodePackages.prettier    |
| stylua                 | pkgs.stylua                   |
| rubocop                | pkgs.rubocop                  |
| puppet-lint            | pkgs.puppet-lint              |

## Notable changes from the lazy.nvim setup

- **No lazy.nvim**: plugins load via Neovim's built-in packpath. Lazy
  loading uses the `lazy = true` spec field, which places plugins in
  `pack/*/opt/` until explicitly loaded.
- **No Mason**: LSP servers come from the Nix store, paths are stable.
- **blink.cmp** replaces the nvim-cmp + LuaSnip stack. Faster, fewer
  plugins, built-in snippet support via friendly-snippets.
- **conform.nvim + nvim-lint** replace none-ls. Cleaner separation of
  formatting vs. linting.
- **Treesitter grammars** pre-built by Nix. No nvim-treesitter plugin
  needed for Neovim 0.10+ — uses built-in auto-discovery.
- **nil_ls**: autoArchive enabled, auto-fetches flake inputs without
  prompting.
- **vim.lsp.config()** replaces deprecated require("lspconfig"). Uses
  Neovim 0.11+ native LSP config.
- **catppuccin 2.0.0+**: uses `variant` instead of `flavour`.
- **bufferline integration**: uses `catppuccin.special.bufferline`.
- **edgy.nvim** removed. neo-tree handles its own positioning; toggleterm
  floats naturally at the bottom.
- **telescope-cheat** removed (wasn't in active use).
- The `sqlite_clib_path` and `puppet_ls` binary path are passed from Nix
  into Lua via the `info` plugin — no hardcoded store paths in Lua files.
