{ config, ... }:
{
  configurations.nixos.amateria.module.home-manager.users.${config.user.username}.imports = [
    (
      { config, ... }:
      {
        # Out-of-store symlink into the repo checkout: writable in place
        # (`ccache -M` writes through the link), no rebuild needed,
        # changes tracked in git.
        xdg.configFile."ccache/ccache.conf".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/hosts/amateria/ccache.conf";
      }
    )
  ];
}
