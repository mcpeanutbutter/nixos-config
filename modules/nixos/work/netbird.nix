{ config, ... }:
let
  userName = config.user.username;
in
{
  flake.modules.nixos.work.imports = [
    (
      { config, ... }:
      {
        # NetBird (WireGuard mesh VPN) — self-hosted management server.
        # Management URL and setup key live in sops (public-repo hygiene, as
        # with the vpn/glpi servers). netbird's `environment` bakes values into
        # the unit at build time, so the URL can't be a sops value there;
        # instead it's fed to the login unit's `netbird up` via NB_MANAGEMENT_URL
        # in a sops-templated env file. The login oneshot loads the setup key
        # (systemd LoadCredential) and runs `netbird up` only when the client
        # reports NeedsLogin — a no-op once a machine is already enrolled.
        services.netbird = {
          # Loosen rp_filter so routes advertised by other peers (work subnets)
          # are usable on this client.
          useRoutingFeatures = "client";

          clients.work = {
            port = 51820;
            login = {
              enable = true;
              setupKeyFile = config.sops.secrets."netbird/setup-key".path;
            };
          };
        };

        # NetBird's hardened daemon can't apply DNS via resolvconf (its
        # ProtectSystem=strict service blocks the write -> "applying resolvconf
        # configuration for nb-work interface: exit status 1"). With
        # systemd-resolved, the upstream module instead grants the daemon the
        # resolve1 D-Bus methods via polkit, which the sandbox allows -- that is
        # what lets NetBird install the pushed `ingenium.trading` split-DNS.
        # See https://wiki.nixos.org/wiki/Netbird.
        services.resolved.enable = true;

        # Route NetworkManager's DNS (incl. the FortiVPN-pushed resolver) through
        # resolved, so both VPNs' DNS coexist as per-link/split domains instead of
        # contending over /etc/resolv.conf.
        networking.networkmanager.dns = "systemd-resolved";

        # Let the desktop user drive the hardened client — both the netbird-work
        # CLI and the netbird-ui-work tray app — without sudo. The daemon's
        # control socket is group-0750 on the netbird-work group.
        users.users.${userName}.extraGroups = [ "netbird-work" ];

        sops.secrets."netbird/setup-key" = { };
        sops.secrets."netbird/management-url" = { };
        sops.templates."netbird-work-env".content = ''
          NB_MANAGEMENT_URL=${config.sops.placeholder."netbird/management-url"}
        '';
        systemd.services.netbird-work-login.serviceConfig.EnvironmentFile =
          config.sops.templates."netbird-work-env".path;
      }
    )
  ];
}
