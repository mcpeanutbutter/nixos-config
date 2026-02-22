{ pkgs, inputs, ... }:
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
  security.pam.services.hyprlock = {};

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
    xfce.thunar
    xfce.thunar-volman # removable media
    xfce.thunar-archive-plugin # archive support
    gnome-text-editor

    # Archive management
    file-roller # archive manager

    # Image viewer
    loupe # GNOME's image viewer (simple and modern)
  ];
}
