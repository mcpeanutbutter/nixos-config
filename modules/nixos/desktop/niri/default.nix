{ pkgs, inputs, ... }:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  # Enable Niri window manager
  programs.niri.enable = true;

  # Enable GDM display manager (minimal setup for Niri)
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

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
    swaylock # screen locker

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
    xfce.thunar # lightweight file manager
    xfce.thunar-volman # removable media
    xfce.thunar-archive-plugin # archive support

    # Archive management
    file-roller # archive manager

    # Image viewer
    loupe # GNOME's image viewer (simple and modern)
  ];
}
