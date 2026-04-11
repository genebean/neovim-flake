# pkgs/puppet-editor-services/default.nix
#
# Builds puppet-editor-services as a Nix package via bundlerApp.
#
# SETUP REQUIRED (one-time, run from this directory):
#   1. Ensure bundix is available: nix shell nixpkgs#bundix
#   2. Run: bundle lock
#   3. Run: bundix
#   This generates Gemfile.lock and gemset.nix which must be committed.
#
# To update to a new version:
#   1. Update the version in Gemfile
#   2. Re-run: bundle lock && bundix
#   3. Commit the updated Gemfile.lock and gemset.nix

{
  bundlerApp,
  bundlerUpdateScript,
  ruby,
  makeWrapper,
  lib,
}:

bundlerApp {
  pname = "puppet-editor-services";
  gemdir = ./.;
  exes = [
    "puppet-languageserver"
    "puppet-debugserver"
  ];

  # puppet-editor-services needs ruby in PATH at runtime
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/puppet-languageserver \
      --prefix PATH : ${lib.makeBinPath [ ruby ]}
    wrapProgram $out/bin/puppet-debugserver \
      --prefix PATH : ${lib.makeBinPath [ ruby ]}
  '';

  passthru.updateScript = bundlerUpdateScript "puppet-editor-services";

  meta = {
    description = "Puppet Language Server for editors (LSP + DAP)";
    homepage = "https://github.com/puppetlabs/puppet-editor-services";
    license = lib.licenses.asl20;
    mainProgram = "puppet-languageserver";
  };
}
