{ inputs, ... }:
{
  hosts.amateria = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.05";
    subpixelLayout = "none"; # mixed OLED/IPS monitors, grayscale AA
    hardwareModule = inputs.nixos-hardware.nixosModules.framework-16-7040-amd;
  };
}
