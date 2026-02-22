{
  hostname,
  nixosModules,
  hostConfig,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    "${nixosModules}/common"
    "${nixosModules}/desktop/${hostConfig.desktopEnvironment}"
    "${nixosModules}/programs/docker"
    "${nixosModules}/services/stylix"
    "${nixosModules}/services/sops"
    "${nixosModules}/services/bitdefender"
    "${nixosModules}/services/clamav"
  ];

  # Set hostname
  networking.hostName = hostname;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
