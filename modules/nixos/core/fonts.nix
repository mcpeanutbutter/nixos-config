{ config, ... }:
{
  flake.modules.nixos.base = nixosArgs: {
    fonts.packages = with nixosArgs.pkgs; [
      maple-mono.NF
      dejavu_fonts
    ];

    fonts.fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      # subpixel rendering depends on the physical panel — per-host data.
      subpixel.rgba = config.hosts.${nixosArgs.config.networking.hostName}.subpixelLayout;
    };
  };
}
