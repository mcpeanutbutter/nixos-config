{
  configurations.nixos.amateria.module =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/5f09259e-0a59-47fe-bfb1-908ec7d12cb3";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-9875292a-e76c-4a6e-938a-95df28d09a58".device =
        "/dev/disk/by-uuid/9875292a-e76c-4a6e-938a-95df28d09a58";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/B075-14C3";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [ ];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted
      # networking (the default) this is the recommended approach.
      networking.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
