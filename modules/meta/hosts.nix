{ lib, ... }:
{
  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.str;
            description = "Nixpkgs system tuple, e.g. \"x86_64-linux\".";
          };

          theme = lib.mkOption {
            type = lib.types.str;
            description = "Base16 scheme name passed to Stylix.";
          };

          stateVersion = lib.mkOption {
            type = lib.types.str;
            description = "NixOS state version for the host.";
          };

          subpixelLayout = lib.mkOption {
            type = lib.types.enum [
              "rgb"
              "bgr"
              "vrgb"
              "vbgr"
              "none"
            ];
            description = "fontconfig subpixel.rgba layout (per-host because monitor types vary).";
          };

          # Waybar temperature widget — set exactly one of thermalZone or hwmon, or
          # leave both null on machines with no usable temperature sensors.
          thermalZone = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Index into /sys/class/thermal/thermal_zone* (Intel/ACPI hosts).";
          };

          hwmon = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  path = lib.mkOption { type = lib.types.str; };
                  input = lib.mkOption { type = lib.types.str; };
                };
              }
            );
            default = null;
            description = "hwmon path + input-filename (AMD hosts without ACPI thermal zones).";
          };

          hardwareModule = lib.mkOption {
            type = lib.types.deferredModule;
            description = ''
              nixos-hardware module (or a list-importing module) for this host's hardware.
              Accepts either a single module like `inputs.nixos-hardware.nixosModules.foo`
              or an aggregating `{ imports = [ ... ]; }` when multiple are needed.
            '';
          };
        };
      }
    );
    default = { };
    description = "Per-host metadata. Each host's data.nix populates one entry.";
  };
}
