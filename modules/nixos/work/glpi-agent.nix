{ lib, ... }:
{
  flake.modules.nixos.work.imports = [
    (
      { config, ... }:
      let
        cfg = config.services.glpiAgent;

        # Same value-formatting logic as the upstream NixOS module.
        formatValue =
          v:
          if lib.isBool v then
            (if v then "1" else "0")
          else if lib.isList v then
            lib.concatStringsSep "," v
          else
            toString v;

        # Filter out settings that are baked into the sops template.
        filteredSettings = lib.filterAttrs (k: _: k != "server" && k != "ca-cert-file") cfg.settings;

        settingsContent = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (k: v: "${k} = ${formatValue v}") filteredSettings
        );
      in
      {
        sops.secrets."glpi/server" = { };
        sops.secrets."glpi/ca-cert" = {
          mode = "0644"; # CA certs are public; DynamicUser needs read access.
        };

        # Sops template merges the sops-interpolated server URL with cfg.settings.
        sops.templates."glpi-agent.cfg" = {
          mode = "0644";
          content = ''
            server = ${config.sops.placeholder."glpi/server"}
            ca-cert-file = ${config.sops.secrets."glpi/ca-cert".path}
            ${settingsContent}
          '';
        };

        services.glpiAgent = {
          enable = true;
          settings = {
            server = "overridden-by-sops"; # satisfies module assertion; real value from sops template
            httpd-trust = "127.0.0.1";
            tasks = "inventory"; # ESX and Deploy require server-side setup
          };
        };

        # Override ExecStart to use the sops-generated config rather than the
        # Nix-store config the upstream module produces.
        systemd.services.glpi-agent.serviceConfig.ExecStart = lib.mkForce (
          lib.escapeShellArgs [
            "${lib.getExe cfg.package}"
            "--conf-file"
            "${config.sops.templates."glpi-agent.cfg".path}"
            "--vardir"
            "${cfg.stateDir}"
            "--daemon"
            "--no-fork"
          ]
        );
      }
    )
  ];
}
