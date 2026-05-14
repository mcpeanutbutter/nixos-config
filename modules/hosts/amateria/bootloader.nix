{
  # Chainload Fedora's GRUB from the Fedora ESP (nvme1n1p1) — amateria
  # dual-boots NixOS + Fedora.
  configurations.nixos.amateria.module.boot.loader.grub.extraEntries = ''
    menuentry "Fedora" {
      search --set=root --fs-uuid BC87-918F
      chainloader /EFI/fedora/shimx64.efi
    }
  '';
}
