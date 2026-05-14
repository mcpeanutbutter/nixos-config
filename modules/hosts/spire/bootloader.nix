{
  # Dual-boot: directly boot the CachyOS kernel from its ESP.
  # (Chainloading systemd-boot from GRUB doesn't work — systemd-boot
  # misidentifies the ESP.)
  configurations.nixos.spire.module.boot.loader.grub.extraEntries = ''
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
}
