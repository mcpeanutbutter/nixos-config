{
  inputs,
  outputs,
  lib,
  config,
  userConfig,
  pkgs,
  ...
}:
{
  # Nixpkgs configuration
  nixpkgs = {
    overlays = [
      outputs.overlays.unstable-packages
      outputs.overlays.custom-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  # Register flake inputs for nix commands
  # nixpkgs registry points to stable; use `nix shell nixpkgs-unstable#pkg` for unstable
  nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) (
    lib.filterAttrs (_: lib.isType "flake") inputs
  );

  # Add inputs to legacy channels
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  # Bootloader - GRUB with EFI support
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = false;
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Europe/Vienna";

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Enable OpenSSH (generates host keys needed by sops-nix)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable power-profiles-daemon for power management
  services.power-profiles-daemon.enable = true;

  # Enable udisks2 for automounting removable media
  services.udisks2.enable = true;

  # Enable gvfs for trash support and mounting in file managers
  services.gvfs.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # User configuration
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.fullName;
    hashedPassword = userConfig.hashedPassword;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Common container config files (Docker added separately via docker module)
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Zsh configuration
  programs.zsh.enable = true;

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    roboto
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    gcc
    glib
    gnumake
    killall
    mesa
    sops
  ];
}
