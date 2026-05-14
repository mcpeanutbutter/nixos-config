{
  # Idle management for the waybar shell stack: auto-lock via hyprlock,
  # before-sleep lock, screen-off, optional battery suspend. Pairs with
  # hyprlock.nix (lock command) and waybar.nix (resume restarts waybar).
  flake.modules.homeManager.waybar.imports = [
    (
      { config, pkgs, ... }:
      let
        lockCmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock &";
        powerOffCmd = "${config.programs.niri.package}/bin/niri msg action power-off-monitors";

        # Suspend only when on battery and the screen is already locked.
        # Desktops have no BAT* entries, so the script no-ops there.
        batterySuspendCmd = pkgs.writeShellScript "idle-battery-suspend" ''
          if ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && \
             ! grep -q 1 /sys/class/power_supply/A*/online 2>/dev/null; then
            pidof hyprlock && systemctl suspend
          fi
        '';
      in
      {
        services.swayidle = {
          enable = true;
          events = [
            {
              event = "before-sleep";
              command = lockCmd;
            }
            {
              event = "lock";
              command = lockCmd;
            }
          ];
          timeouts = [
            {
              timeout = 300; # 5 min — auto-lock
              command = lockCmd;
            }
            {
              timeout = 600; # 10 min — suspend on battery (no-op on AC / desktops)
              command = toString batterySuspendCmd;
            }
            {
              timeout = 900; # 15 min — power off monitors
              command = powerOffCmd;
              resumeCommand = "${pkgs.systemd}/bin/systemctl --user restart waybar.service";
            }
          ];
        };
      }
    )
  ];
}
