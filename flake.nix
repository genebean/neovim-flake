{
  description = "genebean's Neovim configuration - github.com/genebean/neovim-flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-wrapper-modules,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # nix-wrapper-modules exposes a flat lib attrset (not per-system).
      # pkgs carries the system; wlib is system-agnostic.
      wlib = nix-wrapper-modules.lib;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          # Build puppet-editor-services from rubygems
          puppet-editor-services = pkgs.callPackage ./pkgs/puppet-editor-services { };

          # Platform-appropriate sqlite lib name
          sqlite_lib = if pkgs.stdenv.isDarwin then "libsqlite3.dylib" else "libsqlite3.so";

          # The neovim wrapper module.
          # evalPackage takes a list of modules; pkgs is passed as a module arg.
          nvim = wlib.evalPackage [
            { inherit pkgs; }
            (
              { config, lib, ... }:
              {
                imports = [ wlib.wrapperModules.neovim ];

                # ---------------------------------------------------------------
                # Point at the lua directory in the store (pure / locked).
                # For live-edit dev mode, change this to:
                #   lib.generators.mkLuaInline "vim.fn.stdpath('config')"
                # ---------------------------------------------------------------
                settings.config_directory = ./nvim;

                # ---------------------------------------------------------------
                # Pass nix-derived values into lua via the info plugin.
                # Access in lua: require(vim.g.nix_info_plugin_name)(nil, "key")
                # ---------------------------------------------------------------
                info = {
                  sqlite_clib_path = "${pkgs.sqlite.out}/lib/${sqlite_lib}";
                  puppet_ls = "${puppet-editor-services}/bin/puppet-languageserver";
                };

                # ---------------------------------------------------------------
                # LSP servers, formatters, linters, and other runtime tools.
                # These replace Mason entirely.
                # ---------------------------------------------------------------
                extraPackages = with pkgs; [
                  # LSP servers
                  lemminx # XML
                  lua-language-server # Lua
                  nil # Nix
                  puppet-editor-services # Puppet (our bundlerApp)
                  ruff # Python (LSP + linter)

                  # Formatters
                  prettier # HTML, JS, JSON, CSS, YAML, etc.
                  stylua # Lua
                  rubocop # Ruby

                  # Linters
                  puppet-lint # Puppet

                  # Required by plugins
                  sqlite # sqlite.lua (telescope-symbols etc.)
                  gcc # needed if any plugin compiles C at runtime
                ];

                # ---------------------------------------------------------------
                # Plugins
                # ---------------------------------------------------------------
                specs = {
                  # --- Theme (must load first, not lazy) ---
                  catppuccin = {
                    lazy = false;
                    data = pkgs.vimPlugins.catppuccin-nvim;
                  };

                  # --- Dashboard (must load at startup, not lazy) ---
                  alpha = {
                    lazy = false;
                    data = pkgs.vimPlugins.alpha-nvim;
                  };

                  # --- Icons (depended on by many plugins) ---
                  devicons = pkgs.vimPlugins.nvim-web-devicons;

                  # --- UI chrome ---
                  ui = {
                    lazy = false;
                    data = with pkgs.vimPlugins; [
                      bufferline-nvim
                      lualine-nvim
                      noice-nvim
                      nui-nvim # required by noice and neo-tree
                    ];
                  };

                  # --- File tree and navigation ---
                  nav = with pkgs.vimPlugins; [
                    {
                      data = neo-tree-nvim;
                      lazy = false;
                    }
                    plenary-nvim # required by neo-tree, telescope, lazygit
                    telescope-nvim
                    telescope-symbols-nvim
                    telescope-ui-select-nvim
                    todo-comments-nvim
                    which-key-nvim
                    trouble-nvim
                  ];

                  # --- Git ---
                  git = with pkgs.vimPlugins; [
                    gitsigns-nvim
                    vim-fugitive
                    lazygit-nvim
                  ];

                  # --- LSP ---
                  lsp = pkgs.vimPlugins.nvim-lspconfig;

                  # --- Completion (blink.cmp replaces nvim-cmp stack) ---
                  completion = with pkgs.vimPlugins; [
                    blink-cmp
                    friendly-snippets # snippet collection, picked up by blink
                  ];

                  # --- Formatting (replaces none-ls/mason-null-ls) ---
                  formatting = pkgs.vimPlugins.conform-nvim;

                  # --- Linting (replaces none-ls diagnostics sources) ---
                  linting = pkgs.vimPlugins.nvim-lint;

                  # --- Treesitter (grammars pre-built by Nix via withPlugins) ---
                  treesitter = {
                    data = pkgs.vimPlugins.nvim-treesitter.withPlugins (
                      p: with p; [
                        bash
                        css
                        csv
                        diff
                        dockerfile
                        git_config
                        git_rebase
                        gitattributes
                        gitignore
                        go
                        hcl
                        hocon
                        html
                        javascript
                        json
                        lua
                        make
                        markdown
                        markdown_inline
                        nix
                        passwd
                        promql
                        puppet
                        python
                        regex
                        ruby
                        sql
                        ssh_config
                        terraform
                        toml
                        tsv
                        typescript
                        udev
                        vim
                        vimdoc
                        xml
                        yaml
                      ]
                    );
                  };

                  # --- Terminal and tmux ---
                  terminal = with pkgs.vimPlugins; [
                    toggleterm-nvim
                    vim-tmux-navigator
                  ];

                  # --- sqlite.lua: inject clib path before any plugin uses it ---
                  sqlite = {
                    data = pkgs.vimPlugins.sqlite-lua;
                    before = [ "INIT_MAIN" ];
                    config = ''
                      local nixInfo = require(vim.g.nix_info_plugin_name)
                      vim.g.sqlite_clib_path = nixInfo(nil, "sqlite_clib_path")
                    '';
                  };
                };
              }
            )
          ];

        in
        {
          default = nvim;
          inherit nvim;
        }
      );

      # Allow `nix run .` to launch nvim
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nvim";
        };
      });

      # Expose as a home-manager module for use in dots
      homeManagerModules.default = import ./hm-module.nix self;
    };
}
