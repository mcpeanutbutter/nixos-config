{ inputs, ... }:
{
  flake.modules.nixos.base.nixpkgs.overlays = [
    # Expose the unstable channel as `pkgs.unstable.*`. Used selectively
    # for packages that need bleeding-edge versions (e.g. nixd, jetbrains-idea-oss).
    (final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })

    # Custom-packages overlay (replaces the legacy overlays/default.nix
    # custom-packages entry).
    (final: _prev: {
      # Hatter rounded-square icon theme (KDE dark variant).
      hatter-icon-theme = final.callPackage ../../../packages/hatter-icon-theme { };
    })

    # Claude Code with rolling-release packaging.
    inputs.claude-code-nix.overlays.default
  ];
}
