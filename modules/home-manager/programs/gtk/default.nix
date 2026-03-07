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

  # Icon aliases for apps whose desktop entry icon name doesn't match Hatter's
  xdg.dataFile."icons/Hatter-kde-dark/apps/scalable/idea-oss.png".source =
    "${pkgs.hatter-icon-theme}/share/icons/Hatter-kde-dark/apps/scalable/idea.png";
}
