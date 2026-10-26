{ lib, ... }:
let
  # Static color applied to every detected device once detection finishes.
  color = "FFFFFF";
in
{
  # Sapphire RX 9070 XT Pure (GPU i2c), ASRock B550 Extreme4 headers
  # (USB 26ce:01a2, Polychrome USB) and G.Skill Trident Z Neo (ENE DRAM over
  # i2c-piix4). Everything is userspace — a missing device or a crashing
  # server only degrades openrgb.service, never boot.
  configurations.nixos.spire.module =
    { config, ... }:
    let
      cfg = config.services.hardware.openrgb;
    in
    {
      services.hardware.openrgb = {
        enable = true;
        motherboard = "amd";
      };

      # Same server as the nixpkgs module, plus per-device modes applied after
      # detection; in headless --server mode the process keeps serving the SDK.
      # The GPU's LEDs are fed by its ARGB cable from a mainboard header, so the
      # card stays in "External Control" (passthrough) and follows the header.
      # -d matches by case-insensitive substring; an unmatched name makes the
      # server exit, so only the RGB service is affected, never boot.
      systemd.services.openrgb.serviceConfig.ExecStart = lib.mkForce (
        lib.escapeShellArgs [
          (lib.getExe cfg.package)
          "--server"
          "--server-port"
          cfg.server.port
          "--device"
          "ene dram"
          "--mode"
          "static"
          "--color"
          color
          "--device"
          "asrock"
          "--mode"
          "static"
          "--color"
          color
          "--device"
          "sapphire"
          "--mode"
          "external control"
        ]
      );
    };
}
