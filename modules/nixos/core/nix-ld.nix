{
  flake.modules.nixos.base.imports = [
    (
      { pkgs, ... }:
      {
        programs.nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
          ];
        };
      }
    )
  ];
}
