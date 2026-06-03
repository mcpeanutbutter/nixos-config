{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      # GRUB with EFI; chainloading and per-host extra entries live in
      # modules/hosts/<host>/bootloader.nix (added in phase 11).
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = false;
        # Cap GRUB menu entries so old generations can't silently fill the ESP.
        configurationLimit = 64;
      };

      # Latest mainline kernel for best hardware support.
      boot.kernelPackages = pkgs.linuxPackages_latest;
    };
}
