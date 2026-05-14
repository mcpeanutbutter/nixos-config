{ inputs, ... }:
{
  hosts.spire = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.11";
    subpixelLayout = "none"; # OLED display
    hwmon = {
      path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
      input = "temp1_input"; # Tctl (CPU control temp)
    };
    # AMD desktop with no host-specific nixos-hardware module — aggregate the
    # cpu/gpu/ssd modules into one deferredModule via imports.
    hardwareModule = {
      imports = with inputs.nixos-hardware.nixosModules; [
        common-cpu-amd
        common-gpu-amd
        common-pc-ssd
      ];
    };
  };
}
