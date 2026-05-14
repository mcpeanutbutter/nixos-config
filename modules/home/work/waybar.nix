{
  # BSC (BitDefender container) status widget — only on hosts that import the
  # work bucket. The widget config and the modules-right entry both live here
  # so non-work hosts get neither.
  flake.modules.homeManager.work.imports = [
    (
      { pkgs, ... }:
      {
        programs.waybar.settings.mainBar = {
          # Appended to base's modules-right list via module-system list merge.
          # Visual order differs slightly from the legacy layout (BSC ends up
          # after custom/power instead of before it).
          modules-right = [ "custom/BSC" ];

          "custom/BSC" = {
            exec = "${pkgs.writeShellScript "BSC-status" ''
              if ${pkgs.systemd}/bin/systemctl is-active --quiet podman-BSC.service; then
                echo '{"text": "󰒃", "class": "active", "tooltip": "BitDefender: Running"}'
              else
                echo '{"text": "󰒃", "class": "inactive", "tooltip": "BitDefender: Stopped"}'
              fi
            ''}";
            return-type = "json";
            interval = 5;
            on-click = "${pkgs.writeShellScript "BSC-toggle" ''
              if ${pkgs.systemd}/bin/systemctl is-active --quiet podman-BSC.service; then
                ${pkgs.systemd}/bin/busctl call --system org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager StopUnit ss "podman-BSC.service" "replace"
              else
                ${pkgs.systemd}/bin/busctl call --system org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager StartUnit ss "podman-BSC.service" "replace"
              fi
            ''}";
            tooltip = true;
          };
        };
      }
    )
  ];
}
