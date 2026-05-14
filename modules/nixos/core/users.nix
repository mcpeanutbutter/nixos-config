{ config, ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      users.users.${config.user.username} = {
        isNormalUser = true;
        description = config.user.fullName;
        hashedPassword = config.user.hashedPassword;
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    };
}
