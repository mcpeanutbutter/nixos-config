{
  inputs,
  hostname,
  nixosModules,
  hostConfig,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
    "${nixosModules}/common"
    "${nixosModules}/desktop/${hostConfig.desktopEnvironment}"
    "${nixosModules}/programs/docker"
    "${nixosModules}/services/stylix"
    "${nixosModules}/services/sops"
    "${nixosModules}/services/bitdefender"
    "${nixosModules}/services/clamav"
    "${nixosModules}/services/vpn"
    "${nixosModules}/services/glpi-agent"
  ];

  # Chainload Fedora's GRUB from the Fedora ESP (nvme1n1p1)
  boot.loader.grub.extraEntries = ''
    menuentry "Fedora" {
      search --set=root --fs-uuid BC87-918F
      chainloader /EFI/fedora/shimx64.efi
    }
  '';

  # Set hostname
  networking.hostName = hostname;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
