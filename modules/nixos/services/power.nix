{
  flake.modules.nixos.base = {
    services.power-profiles-daemon.enable = true;

    # Automount removable media (USB sticks, optical, etc.).
    services.udisks2.enable = true;

    # Trash + mount support in file managers (yazi, nautilus, etc.).
    services.gvfs.enable = true;
  };
}
