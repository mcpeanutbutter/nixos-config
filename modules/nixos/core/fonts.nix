{ config, ... }:
let
  hostsCfg = config.hosts;
in
{
  flake.modules.nixos.base.imports = [
    (
      {
        pkgs,
        config,
        ...
      }:
      {
        fonts.packages = with pkgs; [
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
          subpixel.rgba = hostsCfg.${config.networking.hostName}.subpixelLayout;
        };
      }
    )
  ];
}
