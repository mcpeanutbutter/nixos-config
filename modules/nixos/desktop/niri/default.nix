{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  # Enable Niri window manager
  programs.niri.enable = true;

  # Enable dconf for GNOME app settings (e.g. GNOME Text Editor)
  programs.dconf.enable = true;

  # Disable GCR SSH agent (enabled by niri-flake via gnome-keyring)
  # so that SSH keys require passphrase entry each time
  services.gnome.gcr-ssh-agent.enable = false;

  # Greetd login manager with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${pkgs.niri}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };

  # PAM service for hyprlock authentication
  security.pam.services.hyprlock = { };

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Use niri from nixpkgs instead of niri-flake's niri-unstable
  programs.niri.package = pkgs.niri;

  # Bluetooth support (not in niri-flake defaults)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Power management (not in niri-flake defaults)
  services.upower.enable = true;

  # Replace niri-flake's broken polkit-kde-agent with polkit-gnome
  # (polkit-kde-agent fails to register with the host portal outside Plasma)
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

  # Essential Niri packages
  environment.systemPackages = with pkgs; [
    # Basic Wayland utilities
    fuzzel # application launcher
    mako # notification daemon
    waybar # status bar
    hyprlock # screen locker

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
    file-roller # archive manager

    # Image viewer
    loupe # GNOME's image viewer (simple and modern)
  ];
}
