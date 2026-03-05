{ pkgs, config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.oxylite-icon-theme.override { folderColor = "${colors.base0A}"; };
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
