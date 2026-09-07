{
  flake.modules.homeManager.base = {
    gtk = {
      enable = true;

      # iconTheme is set by stylix.icons (see modules/nixos/services/stylix.nix)
      # — single source of truth so qt5ct/qt6ct get the same value.
      # gtk3/gtk4 themes are set by stylix's gtk target (it assigns
      # gtk.theme = adw-gtk3 and gtk.gtk4.theme = config.gtk.theme).

      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    dconf.settings."org/gnome/desktop/interface".icon-theme = "Hatter-kde-dark";
  };
}
