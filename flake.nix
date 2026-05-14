{
  description = "NixOS configuration";

  inputs = {
    # Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Dendritic pattern: flake-parts + auto-import via import-tree
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # Automated ricing. Pinned to the merge commit of nix-community/stylix#2189
    # (noctalia-shell foreground grays → accent colors) — the fix wasn't
    # backported to release-25.11, and current master needs `services.displayManager.generic`
    # which only exists on nixos-unstable. This commit is the sweet spot.
    stylix.url = "github:danth/stylix/044ac0cc6d914f1dac22a728013bc3797f77cfab";

    # Niri compositor
    niri.url = "github:sodiboo/niri-flake";

    # Noctalia shell (Quickshell-based). Upstream requires nixpkgs-unstable
    # because it depends on a recent Quickshell.
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific optimizations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Claude Code
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
