{
  # BSC (BitDefender container) status widget — only on hosts that import the
  # work bucket. The widget config and the modules-right entry both live here
  # so non-work hosts get neither.
  flake.modules.homeManager.work.imports = [
    (
      { lib, pkgs, ... }:
      {
        programs.waybar.settings.mainBar = {
          # mkOrder 1200 slots BSC between the base list (default priority 1000)
          # and custom/power (mkAfter, priority 1500), restoring the legacy
          # ordering where BSC sits just before the power button.
          modules-right = lib.mkOrder 1200 [ "custom/BSC" ];

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

        # Base CSS rounds night-light's right corner so it caps Pill 7 on
        # non-work hosts. On work hosts BSC is the cap instead, so flatten
        # night-light again. mkAfter ensures this rule wins over the base
        # rule (which is at mkOrder 1200).
        programs.waybar.style = lib.mkAfter ''
          #custom-night-light {
            margin: 0.3em 0em;
            border-radius: 0px;
          }
        '';
      }
    )
  ];
}
