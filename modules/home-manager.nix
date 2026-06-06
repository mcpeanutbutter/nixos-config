{ config, inputs, ... }:
{
  # Make every host's nixos `base` bucket pull in home-manager (as a NixOS
  # module) plus the user's home-manager `base` bucket. Hosts that also import
  # the nixos `work` bucket additionally get the home-manager `work` bucket
  # merged into the user's HM config.
  #
  # Pattern lifted from mightyiam/infra modules/home-manager/nixos.nix.

  flake.modules.nixos.base = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";

      sharedModules = [
        inputs.nixvim.homeModules.nixvim
        inputs.sops-nix.homeModules.sops
      ];

      users.${config.user.username} = {
        imports = [
          (
            { osConfig, ... }:
            {
              home.stateVersion = osConfig.system.stateVersion;
            }
          )
          config.flake.modules.homeManager.base
        ];
      };
    };
  };

  flake.modules.nixos.work = {
    home-manager.users.${config.user.username}.imports = [
      config.flake.modules.homeManager.work
    ];
  };

  flake.modules.nixos.noctalia = {
    home-manager.users.${config.user.username}.imports = [
      config.flake.modules.homeManager.noctalia
    ];
  };

  # Declare empty bucket containers so writers don't have to define them.
  flake.modules.homeManager.base = { };
  flake.modules.homeManager.work = { };
  flake.modules.homeManager.noctalia = { };
}
