{
  description = "NixOS configuration";

  inputs = {
    # Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

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
    # Automated ricing
    stylix.url = "github:danth/stylix/release-25.11";

    # Niri compositor
    niri.url = "github:sodiboo/niri-flake";

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      vscode-extensions = inputs.nix-vscode-extensions.extensions.${system};

      # Define user configurations
      users = {
        jonas = import ./users/jonas;
      };

      # Define host configurations
      hosts = {
        amateria = {
          system = "x86_64-linux";
          theme = "material-darker";
          stateVersion = "25.05";
          desktopEnvironment = "niri";
          thermalZone = null; # TODO: determine on amateria (look for k10temp zone)
        };
        selenitic = {
          system = "x86_64-linux";
          theme = "material-darker";
          stateVersion = "25.05";
          desktopEnvironment = "niri";
          thermalZone = 5; # x86_pkg_temp (CPU package temp)
        };
        spire = {
          system = "x86_64-linux";
          theme = "material-darker";
          stateVersion = "25.11";
          desktopEnvironment = "niri";
          thermalZone = null; # Determine on spire hardware later
        };
      };

      # Function for NixOS system configuration
      mkNixosConfiguration =
        hostname: username:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs hostname;
            userConfig = users.${username};
            hostConfig = hosts.${hostname};
            nixosModules = "${self}/modules/nixos";
          };
          modules = [
            ./hosts/${hostname}
            inputs.stylix.nixosModules.stylix
            inputs.sops-nix.nixosModules.sops

            # Make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.${username} = import ./home/${username}/${hostname};

              home-manager.extraSpecialArgs = {
                inherit inputs outputs vscode-extensions;
                userConfig = users.${username};
                hostConfig = hosts.${hostname};
                nhModules = "${self}/modules/home-manager";
              };

              home-manager.sharedModules = [
                inputs.nixvim.homeModules.nixvim
                inputs.sops-nix.homeModules.sops
              ];
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        amateria = mkNixosConfiguration "amateria" "jonas";
        selenitic = mkNixosConfiguration "selenitic" "jonas";
        spire = mkNixosConfiguration "spire" "jonas";
      };

      overlays = import ./overlays { inherit inputs; };
    };
}
