{ inputs, config, ... }:
let
  hostsCfg = config.hosts;
in
{
  flake.modules.nixos.base.imports = [
    inputs.stylix.nixosModules.stylix
    (
      {
        pkgs,
        config,
        ...
      }:
      {
        # stylix master targets nixos-unstable; these targets define option
        # paths that don't exist in 26.05 (services.displayManager.regreet,
        # services.kmscon.config) even when disabled. Neither is used here.
        disabledModules = [
          "${inputs.stylix}/modules/regreet/nixos.nix"
          "${inputs.stylix}/modules/kmscon/nixos.nix"
        ];

        stylix = {
          enable = true;
          # Deliberately on master with nixpkgs 26.05 (see flake.nix).
          enableReleaseChecks = false;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/${
            hostsCfg.${config.networking.hostName}.theme
          }.yaml";
          # Follow the scheme's own `variant:` field (dark/light).
          polarity = config.lib.stylix.colors.variant;

          cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
            size = 32;
          };

          fonts = {
            monospace = {
              package = pkgs.maple-mono.NF;
              name = "Maple Mono NF";
            };
            sansSerif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans";
            };
            serif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Serif";
            };
            emoji = {
              package = pkgs.noto-fonts-color-emoji;
              name = "Noto Color Emoji";
            };
            sizes = {
              applications = 12;
              terminal = 12;
              desktop = 10;
              popups = 12;
            };
          };

          opacity = {
            applications = 0.8;
            terminal = 0.8;
            desktop = 0.8;
            popups = 0.8;
          };

          # Icon theme. Propagates to gtk.iconTheme (via stylix/hm/icons.nix)
          # and to the icon_theme key in qt5ct/qt6ct.conf (via stylix's qt
          # target). Without this, Qt apps fall back to
          # hicolor and show missing-icon checkerboards for most apps.
          icons = {
            enable = true;
            package = pkgs.hatter-icon-theme;
            dark = "Hatter-kde-dark";
            light = "Hatter-kde";
          };

          targets = {
            # Disable browser theming to avoid "managed by organization" issues.
            chromium.enable = false;

            # This target patches gtksourceview{,4,5} through a nixpkgs overlay
            # (postFixup copies stylix.xml into the package), which makes every
            # consumer a cache miss on each nixpkgs bump — inkscape then rebuilds
            # from source. The home-manager target installs the same file into
            # ~/.local/share/gtksourceview-*/styles, so this is redundant.
            gtksourceview.enable = false;
          };
        };
      }
    )
  ];
}
