{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        gcc
        glib
        gnumake
        killall
        mesa
        sops
      ];
    };
}
