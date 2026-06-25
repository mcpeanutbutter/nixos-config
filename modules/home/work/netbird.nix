{
  # NetBird tray UI (StatusNotifierItem) — surfaces the mesh VPN in noctalia's
  # Tray widget. netbird isn't a NetworkManager connection, so the NM-based
  # Network/VPN widgets can't see it. netbird-ui-work is the per-client wrapper
  # from services.netbird (on the system PATH); reaching the daemon socket needs
  # membership in the netbird-work group (granted in nixos/work/netbird.nix).
  # Group membership applies on next login, so the tray icon appears then.
  flake.modules.homeManager.work.systemd.user.services.netbird-ui = {
    Unit = {
      Description = "NetBird tray UI";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "/run/current-system/sw/bin/netbird-ui-work";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
