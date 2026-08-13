{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      # GRUB with EFI; chainloading and per-host extra entries live in
      # modules/hosts/<host>/bootloader.nix (added in phase 11).
      # false: the UEFI variable store is nearly exhausted (1,039 B free of
      # 151,464 as of BIOS 04.05, below the kernel's 5,120 B write reserve),
      # so grub-install must not touch NVRAM. Boot0000 already exists and
      # leads BootOrder; grub-install still updates /boot with --no-nvram.
      # See https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/90
      boot.loader.efi.canTouchEfiVariables = false;
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        # Also install to the fallback path \EFI\BOOT\BOOTX64.EFI so the
        # machine boots even if the Boot0000 NVRAM entry is ever lost.
        # Note: this replaces the systemd-boot copy that previously lived there.
        efiInstallAsRemovable = true;
        device = "nodev";
        useOSProber = false;
        # Cap GRUB menu entries so old generations can't silently fill the ESP.
        configurationLimit = 64;
      };

      # Latest mainline kernel for best hardware support.
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
