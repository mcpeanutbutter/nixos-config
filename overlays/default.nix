{ inputs, ... }:
{
  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # Custom package overrides
  custom-packages = final: prev: {
    # Fix missing xrdb alias - home-manager xresources module expects pkgs.xrdb
    xrdb = prev.xorg.xrdb;

    # Oxylite skeuomorphic icon theme (disabled, kept for reference)
    # oxylite-icon-theme = final.callPackage ../packages/oxylite-icon-theme { };

    # Hatter rounded-square icon theme (KDE dark variant)
    hatter-icon-theme = final.callPackage ../packages/hatter-icon-theme { };
  };
}
