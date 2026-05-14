{ inputs, ... }:
{
  flake.modules.homeManager.noctalia.imports = [
    inputs.noctalia.homeModules.default
    {
      programs.noctalia-shell = {
        enable = true;

        # Use the system icon theme (Hatter-kde-dark via gtk.nix) instead of
        # noctalia's bundled Tabler icon font. Apps without a Tabler-named
        # icon would otherwise fall back to a missing-icon checkerboard.
        settings.appLauncher.iconMode = "native";
      };

      # Stylix's noctalia target auto-enables via stylix.autoEnable (true
      # in modules/nixos/services/stylix.nix), but we set it explicitly so
      # the wiring is grep-able.
      stylix.targets.noctalia-shell.enable = true;
    }
  ];
}
