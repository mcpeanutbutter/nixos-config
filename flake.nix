{
  description = "NixOS configuration";

  inputs = {
    # Nixpkgs — qualified names only (no bare nixpkgs).
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    # Dendritic pattern: flake-parts + auto-import via import-tree
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-stable";
    };
    import-tree.url = "github:vic/import-tree";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    # Track the release branch matching nixpkgs-stable — master is developed
    # against nixos-unstable and drifts on options like services.kmscon.config.
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Niri compositor
    niri.url = "github:sodiboo/niri-flake";

    # Pinned to the legacy-v4 branch: the default branch went to the v5 C++
    # rewrite (native Wayland/OpenGL-ES, no Quickshell), which renames the HM
    # option to programs.noctalia and changes the settings schema to TOML —
    # incompatible with everything in modules/home/noctalia/. legacy-v4 keeps
    # programs.noctalia-shell and still gets v4 bugfixes. Revisit for a v5
    # migration later.
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Hardware-specific optimizations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Claude Code
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
