{ inputs, ... }:
{
  hosts.amateria = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.05";
    subpixelLayout = "none"; # mixed OLED/IPS monitors, grayscale AA
    hwmon = {
      path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
      input = "temp1_input"; # Tctl (CPU control temp)
    };
    hardwareModule = inputs.nixos-hardware.nixosModules.framework-16-7040-amd;
  };
}
