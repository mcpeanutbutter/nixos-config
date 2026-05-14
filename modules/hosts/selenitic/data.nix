{ inputs, ... }:
{
  hosts.selenitic = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.05";
    subpixelLayout = "rgb"; # standard IPS panel
    thermalZone = 5; # x86_pkg_temp (CPU package temp)
    hardwareModule = inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s;
  };
}
