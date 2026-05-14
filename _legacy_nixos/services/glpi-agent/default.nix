{ config, lib, ... }:
let
  cfg = config.services.glpiAgent;

  # Same formatting logic as the upstream NixOS module
  formatValue =
    v:
    if lib.isBool v then
      if v then "1" else "0"
    else if lib.isList v then
      lib.concatStringsSep "," v
    else
      toString v;

  # Filter settings that are handled by the sops template
  filteredSettings = lib.filterAttrs (k: _: k != "server" && k != "ca-cert-file") cfg.settings;

  settingsContent = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "${k} = ${formatValue v}") filteredSettings
  );
in
{
  # Sops secrets
  sops.secrets."glpi/server" = { };
  sops.secrets."glpi/ca-cert" = {
    mode = "0644"; # CA certs are public; DynamicUser needs read access
  };

  # Sops template: merges sops-interpolated server URL with all other cfg.settings
  sops.templates."glpi-agent.cfg" = {
    mode = "0644"; # DynamicUser needs read access
    content = ''
      server = ${config.sops.placeholder."glpi/server"}
      ca-cert-file = ${config.sops.secrets."glpi/ca-cert".path}
      ${settingsContent}
    '';
  };

  # Enable the built-in GLPI agent service (provides systemd hardening, DynamicUser, etc.)
  services.glpiAgent = {
    enable = true;
    settings = {
      server = "overridden-by-sops"; # Satisfies module assertion; actual value from sops template
      httpd-trust = "127.0.0.1";
      tasks = "inventory"; # Only run inventory; ESX and Deploy require server-side setup
    };
  };

  # Override ExecStart to use our sops-generated config instead of the Nix store one
  systemd.services.glpi-agent.serviceConfig.ExecStart = lib.mkForce (lib.escapeShellArgs [
    "${lib.getExe cfg.package}"
    "--conf-file"
    "${config.sops.templates."glpi-agent.cfg".path}"
    "--vardir"
    "${cfg.stateDir}"
    "--daemon"
    "--no-fork"
  ]);
}
