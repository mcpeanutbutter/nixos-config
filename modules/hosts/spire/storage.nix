{
  configurations.nixos.spire.module = {
    # Encrypted data drive (nvme1n1p1) — auto-unlocked at boot via a keyfile
    # stored on the encrypted root.
    boot.initrd.luks.devices."data" = {
      device = "/dev/disk/by-uuid/86dcdb91-0c35-48fe-b810-7f0cc26f15eb";
      keyFile = "/root/data-drive.key";
    };
    boot.initrd.secrets."/root/data-drive.key" = /root/data-drive.key;

    fileSystems."/home/jonas/data" = {
      device = "/dev/mapper/data";
      fsType = "ext4";
      options = [
        "nofail"
        "defaults"
      ];
    };
  };
}
