{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, ... }:
      {
        gtk = {
          enable = true;

          # iconTheme is set by stylix.icons (see modules/nixos/services/stylix.nix)
          # — single source of truth so qt5ct/qt6ct get the same value.

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
