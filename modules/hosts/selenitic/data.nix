{ inputs, ... }:
{
  hosts.selenitic = {
    system = "x86_64-linux";
    theme = "everforest-dark-hard";
    stateVersion = "25.05";
    subpixelLayout = "rgb"; # standard IPS panel
    hardwareModule = inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s;
  };
}
