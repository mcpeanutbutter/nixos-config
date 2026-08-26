{
  # The USB-C dock has an illuminated "lock" button whose MCU enumerates as
  # Maxxter 248a:8873 "USB LOCK KEY" on the dock's internal hub. Its HID
  # descriptor is a generic composite: a mouse with 16-bit *relative* X/Y over
  # ±32767 (one stray report flings the pointer into a screen corner), plus a
  # boot keyboard and a System Control collection that can emit power/sleep.
  # The button is unused, so drop the device before it binds.
  flake.modules.nixos.base.services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="248a", ATTR{idProduct}=="8873", ATTR{authorized}="0"
  '';
}
