{ inputs, ... }:
{
  hosts.selenitic = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.05";
    subpixelLayout = "rgb"; # standard IPS panel
    hardwareModule = inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s;
  };
}
