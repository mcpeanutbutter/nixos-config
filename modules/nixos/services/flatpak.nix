{ inputs, ... }:
{
  flake.modules.nixos.base.imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    {
      services.flatpak = {
        enable = true;
        # Brave was dropped from nixpkgs (NixOS/nixpkgs#582838); the Flathub
        # build is verified by Brave Software. Wiring in
        # modules/home/programs/brave.nix.
        packages = [ "com.brave.Browser" ];
        # Browser: daily rather than nix-flatpak's weekly default.
        update.auto = {
          enable = true;
          onCalendar = "daily";
        };
      };
    }
  ];
}
