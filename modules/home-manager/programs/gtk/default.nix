{ pkgs, ... }:
{
  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.oxylite-icon-theme;
      name = "oxylite";
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = "oxylite";
  };
}
