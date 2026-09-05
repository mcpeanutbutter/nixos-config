{ inputs, ... }:
{
  flake.modules.homeManager.noctalia.imports = [
    inputs.noctalia.homeModules.default
    (
      { config, pkgs, ... }:
      {
        programs.noctalia = {
          enable = true;
          # HM's startServices restarts the unit when the binary/config changes,
          # so a rebuild picks up new noctalia versions without re-login.
          systemd.enable = true;

          # Only diffs against v5 defaults (https://docs.noctalia.dev/noctalia/configuration/shell/).
          # Colors, fonts, wallpaper default and popup opacities come from the
          # stylix `noctalia` target.
          settings = {
            shell = {
              # System avatar installed by modules/nixos/noctalia/greeter.nix.
              avatar_path = "/var/lib/AccountsService/icons/jonas";
              # Config is declarative; never open the first-run wizard.
              setup_wizard_enabled = false;
              # Bar-button panels drop next to the clicked widget instead of the bar centre.
              panel = {
                open_near_click_control_center = true;
                open_near_click_session = true;
              };
              # Push wallpaper + palette to noctalia-greeter (modules/nixos/noctalia/greeter.nix)
              # whenever they change; polkit lets our user do it without a prompt.
              greeter_sync.auto_sync = true;
            };

            # Stylix owns GTK/Qt/terminal theming.
            theme.templates = {
              enable_builtin_templates = false;
              enable_community_templates = false;
            };

            bar.default = {
              thickness = 40;
              # Same corner radius as niri windows (modules/home/desktop/niri/enable.nix).
              radius = 8;
              margin_edge = 24;
              margin_ends = 128;
              # Monospace bar; the shell-wide font (launcher, panels) stays stylix sans.
              font_family = config.stylix.fonts.monospace.name;
              # The stylix target sets dock/notification/osd opacity but not the bar.
              background_opacity = config.stylix.opacity.desktop;
              start = [
                "launcher"
                "spacer"
                "sysmon-cpu"
                "sysmon-temp"
                "sysmon-mem"
                "sysmon-net"
                "sysmon-up"
                "spacer"
                "workspaces"
                "spacer"
                "taskbar"
              ];
              center = [ "clock" ];
              end = [
                "media"
                "spacer"
                "notifications"
                "tray"
                "volume"
                "mic"
                "brightness"
                "battery"
                "network"
                "bluetooth"
                "nightlight"
                "control-center"
              ];
            };

            widget = {
              # Stock NixOS snowflake (transparent, fills the viewBox). The Hatter
              # variant is an app badge on a rounded square, so it renders small.
              # Image size is fixed at 16 px × bar scale; there is no per-widget size.
              launcher.custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              # sysmon shows one statistic per instance; no gauge bar next to the value.
              sysmon-cpu = {
                type = "sysmon";
                stat = "cpu_usage";
                visualization = "none";
              };
              sysmon-temp = {
                type = "sysmon";
                stat = "cpu_temp";
                visualization = "none";
              };
              sysmon-mem = {
                type = "sysmon";
                stat = "ram_used";
                visualization = "none";
              };
              sysmon-net = {
                type = "sysmon";
                stat = "net_rx";
                visualization = "none";
              };
              sysmon-up = {
                type = "sysmon";
                stat = "net_tx";
                visualization = "none";
              };
              # Gaps between widget groups (no pills in v5).
              spacer.length = 12;
              # Named workspaces (modules/home/desktop/niri/workspaces.nix) read
              # as "HUB"; unnamed ones fall back to their index.
              workspaces = {
                label_source = "name";
                max_label_chars = 3;
              };
              taskbar = {
                # Icons are 16 px × icon_scale regardless of bar thickness.
                icon_scale = 1.5;
                item_spacing = 0;
                only_active_workspace = true;
              };
              clock.format = "{:%H:%M} · {:%a, %b %d}";
              media.hide_when_no_media = true;
              tray = {
                drawer = true;
                hide_passive = false;
              };
              mic = {
                type = "volume";
                device = "input";
              };
            };

            location.address = "Vienna";
            # Schedule follows sunrise/sunset from location.
            nightlight.enabled = true;

            idle.behavior = {
              screen-off.timeout = 300;
              lock.enabled = false;
              suspend.enabled = false;
            };

            wallpaper = {
              directory = "/home/jonas/Pictures/Wallpapers";
              transition = [ "fade" ];
              automation = {
                enabled = true;
                interval_seconds = 1800;
              };
            };
            # Blurred wallpaper copy placed in niri's overview backdrop
            # (layer-rule in niri-glue.nix).
            backdrop.enabled = true;
          };
        };

        # Auto-enabled by stylix.autoEnable; explicit so the wiring is grep-able.
        stylix.targets.noctalia.enable = true;
      }
    )
  ];
}
