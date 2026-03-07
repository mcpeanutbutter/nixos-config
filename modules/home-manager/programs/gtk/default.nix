{ pkgs, ... }:
{
  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.hatter-icon-theme;
      name = "Hatter-kde-dark";
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = "Hatter-kde-dark";
  };
}
