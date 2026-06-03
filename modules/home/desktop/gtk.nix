{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, config, ... }:
      {
        gtk = {
          enable = true;

          # iconTheme is set by stylix.icons (see modules/nixos/services/stylix.nix)
          # — single source of truth so qt5ct/qt6ct get the same value.

          # Pin pre-26.05 behavior: gtk4 inherits the gtk3 theme (HM default became null).
          gtk4.theme = config.gtk.theme;

          gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
          gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
        };

        dconf.settings."org/gnome/desktop/interface".icon-theme = "Hatter-kde-dark";

        # Icon alias for apps whose desktop-entry icon name doesn't match Hatter's.
        xdg.dataFile."icons/Hatter-kde-dark/apps/scalable/idea-oss.png".source =
          "${pkgs.hatter-icon-theme}/share/icons/Hatter-kde-dark/apps/scalable/idea.png";
      }
    )
  ];
}
