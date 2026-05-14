{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.clamav ];
      services.clamav.daemon.enable = true;
      services.clamav.updater.enable = true;
    };
}
