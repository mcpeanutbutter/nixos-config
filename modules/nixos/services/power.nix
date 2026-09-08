{
  flake.modules.nixos.base = {
    services.power-profiles-daemon.enable = true;

    # The Shokz OpenMeet UC dongle (3511:2f06) emits phantom KEY_POWER presses
    # when the headset powers on, which suspended the system ("screens go
    # black"). Device-level fixes are all worse: udev TAG-="power-switch" is
    # ignored on hotplug, hwdb can't remap the ~3300 fields sharing the usage,
    # and de-authorizing the HID interfaces makes the dongle firmware reset on
    # any button press. The suspend actor was niri's built-in power-key
    # handling (disabled in modules/home/desktop/niri/enable.nix); with that
    # gone, logind's default (poweroff!) would take over, so ignore it here
    # too. The hardware button still force-offs via long-press. Note logind
    # only picks this up on restart/reboot, not on nixos-rebuild switch.
    services.logind.settings.Login.HandlePowerKey = "ignore";

    # On mains power a lid close locks the session instead of suspending on the
    # spot; noctalia's 15-minute idle suspend takes over from there. Docked
    # (more than one display) already falls to HandleLidSwitchDocked=ignore, and
    # on battery HandleLidSwitch=suspend stays. Same restart caveat as above.
    services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";

    # Automount removable media (USB sticks, optical, etc.).
    services.udisks2.enable = true;

    # Trash + mount support in file managers (yazi, nautilus, etc.).
    services.gvfs.enable = true;
  };
}
