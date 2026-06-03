{ inputs, lib, ... }:
{
  flake.modules.nixos.base.imports = [
    inputs.niri.nixosModules.niri
    (
      { pkgs, ... }:
      {
        programs.niri.enable = true;
        # From nixpkgs-stable: newer than niri-flake's niri-stable, and has background-effect blur.
        programs.niri.package = pkgs.niri;

        # Dconf for GNOME app settings (e.g. GNOME Text Editor).
        programs.dconf.enable = true;

        # Disable GCR SSH agent (enabled by niri-flake via gnome-keyring) so
        # SSH keys require passphrase entry each time.
        services.gnome.gcr-ssh-agent.enable = false;

        # Greetd login manager with tuigreet.
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${pkgs.niri}/share/wayland-sessions";
              user = "greeter";
            };
          };
        };

        # US keymap with altgr-intl (Euro, accented chars on AltGr combos).
        services.xserver.xkb = {
          layout = "us";
          variant = "altgr-intl";
        };

        # Bluetooth (not enabled by niri-flake defaults).
        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;
        services.blueman.enable = true;

        # Power management (not enabled by niri-flake defaults).
        services.upower.enable = true;

        # Thumbnailer daemon used by Nemo over D-Bus. Without it, Nemo's
        # inline GdkPixbuf fallback is unreliable — the actual cause of
        # "thumbnails only sometimes appear".
        services.tumbler.enable = true;

        # niri-flake pulls in xdg-desktop-portal-gnome but gnome.portal has
        # `UseIn=gnome`, so on niri none of its interfaces (ScreenCast, Settings,
        # Notification, ...) are auto-selected — screen sharing in Brave/Teams
        # ends up with no ScreenCast backend. Make gnome the explicit default
        # for all portals, then override FileChooser to use the GTK portal
        # (avoids gnome's Nautilus delegation, which we don't have since we use
        # Nemo).
        xdg.portal = {
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          config.common = {
            default = [ "gnome" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
        };

        # Replace niri-flake's broken polkit-kde-agent with polkit-gnome
        # (polkit-kde-agent fails to register with the host portal outside Plasma).
        systemd.user.services.niri-flake-polkit = lib.mkForce {
          description = "PolicyKit Authentication Agent";
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          wantedBy = [ "niri.service" ];
          serviceConfig = {
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Type = "simple";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        # Essential Niri-suite packages. Shell-specific tools (fuzzel, mako,
        # waybar, hyprlock) live in the waybar bucket and are installed via
        # home-manager when that bucket is active.
        environment.systemPackages = with pkgs; [
          # Screenshot and clipboard
          grim
          slurp
          wl-clipboard

          # System controls
          brightnessctl
          pamixer
          pavucontrol

          # Media control
          playerctl

          # Network management
          networkmanagerapplet # nm-applet for system tray

          # File management
          nemo-with-extensions # Cinnamon file manager (GTK, dual pane, extensions)
          cinnamon-desktop # gsettings schemas for Nemo (terminal, default apps)
          gnome-text-editor

          # Archive management
          file-roller

          # Image viewer
          loupe # GNOME's image viewer
        ];
      }
    )
  ];
}
