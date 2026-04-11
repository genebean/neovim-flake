# hm-module.nix
# Usage in your dots flake.nix:
#
#   inputs.genebean-neovim = {
#     url = "github:genebean/neovim-flake";
#     inputs.nixpkgs.follows = "nixpkgs";
#   };
#
# Then in your home configuration:
#
#   imports = [ inputs.genebean-neovim.homeManagerModules.default ];
#
# This removes the need for home.file symlinks and programs.neovim in general/default.nix.

self:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.genebean-neovim;
in
{
  options.programs.genebean-neovim = {
    enable = lib.mkEnableOption "genebean's neovim configuration";
    defaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set EDITOR and VISUAL to nvim";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.sessionVariables = lib.mkIf cfg.defaultEditor {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
