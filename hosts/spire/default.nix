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
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
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

  # Set hostname
  networking.hostName = hostname;
  
  # Dual-boot: directly boot CachyOS kernel from its ESP
  # (chainloading systemd-boot doesn't work — it misidentifies the ESP)
  boot.loader.grub.extraEntries = ''
    menuentry "CachyOS" {
      search --set=root --fs-uuid 0F06-0878
      linux /vmlinuz-linux-cachyos root=UUID=db42ec0c-8329-4fa2-b304-069e6b60fc98 rw rd.luks.name=52464ea2-b6fc-4475-9c06-84a99764766d=luks-52464ea2-b6fc-4475-9c06-84a99764766d zswap.enabled=0 nowatchdog quiet splash
      initrd /initramfs-linux-cachyos.img
    }
    menuentry "CachyOS (LTS)" {
      search --set=root --fs-uuid 0F06-0878
      linux /vmlinuz-linux-cachyos-lts root=UUID=db42ec0c-8329-4fa2-b304-069e6b60fc98 rw rd.luks.name=52464ea2-b6fc-4475-9c06-84a99764766d=luks-52464ea2-b6fc-4475-9c06-84a99764766d zswap.enabled=0 nowatchdog quiet splash
      initrd /initramfs-linux-cachyos-lts.img
    }
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
