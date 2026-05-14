{ inputs, lib, ... }:
{
  flake.modules.nixos.base = nixosArgs: {
    nixpkgs.config.allowUnfree = true;

    # Register flake inputs for `nix` commands. nixpkgs registry points at
    # stable; use `nix shell nixpkgs-unstable#pkg` to reach unstable.
    nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) (
      lib.filterAttrs (_: lib.isType "flake") inputs
    );

    # Make `<flake>` channel-style paths work too (etc/nix/path/<input>).
    nix.nixPath = [ "/etc/nix/path" ];
    environment.etc = lib.mapAttrs' (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    }) nixosArgs.config.nix.registry;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };
}
