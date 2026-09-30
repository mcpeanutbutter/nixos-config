{
  flake.modules.homeManager.base.imports = [
    (
      { lib, config, ... }:
      {
        gtk = {
          enable = true;

          # iconTheme is set by stylix.icons (see modules/nixos/services/stylix.nix)
          # — single source of truth so qt5ct/qt6ct get the same value; HM's gtk3
          # module mirrors it into dconf. gtk3/gtk4 themes are set by stylix's gtk
          # target (it assigns gtk.theme = adw-gtk3 and gtk.gtk4.theme = config.gtk.theme).

          # Only for dark: "light" would make HM write dconf color-scheme =
          # "prefer-light", conflicting with stylix's "default".
          colorScheme = lib.mkIf (config.stylix.polarity == "dark") "dark";
        };
      }
    )
  ];
}
