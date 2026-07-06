{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      hardware.keyboard.qmk.enable = true;
      environment.systemPackages = [ pkgs.qmk ];
    };
}
