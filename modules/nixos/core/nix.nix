{ inputs, lib, ... }:
let
  # Flake inputs (incl. self), used for the registry and <input> channel paths.
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in
{
  flake.modules.nixos.base.imports = [
    {
      nixpkgs.config.allowUnfree = true;

      # Register every flake input for `nix` commands (nix shell nixpkgs-stable#pkg, …).
      nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;

      # Expose the same inputs as <input> channel paths via /etc/nix/path.
      nix.nixPath = [ "/etc/nix/path" ];
      environment.etc = lib.mapAttrs' (name: flake: {
        name = "nix/path/${name}";
        value.source = flake;
      }) flakeInputs;

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };

      # Weekly GC of 30-day-old generations so the store and ESP don't fill up.
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    }
  ];
}
