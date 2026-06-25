{
  flake.modules.nixos.work.imports = [
    (
      {
        config,
        pkgs,
        ...
      }:
      {
        # FortiSSLVPN NetworkManager plugin (uses openfortivpn backend; supports
        # declarative credentials via NM ensureProfiles).
        networking.networkmanager.plugins = [ pkgs.networkmanager-fortisslvpn ];

        sops.secrets."vpn/server" = { };
        sops.secrets."vpn/username" = { };
        sops.secrets."vpn/password" = { };

        sops.templates."vpn-env".content = ''
          VPN_SERVER=${config.sops.placeholder."vpn/server"}
          VPN_USER=${config.sops.placeholder."vpn/username"}
          VPN_PASSWORD=${config.sops.placeholder."vpn/password"}
        '';

        networking.networkmanager.ensureProfiles = {
          environmentFiles = [ config.sops.templates."vpn-env".path ];
          profiles.work-vpn = {
            connection = {
              id = "Work VPN";
              type = "vpn";
              autoconnect = "false";
            };
            vpn = {
              service-type = "org.freedesktop.NetworkManager.fortisslvpn";
              gateway = "$VPN_SERVER";
              user = "$VPN_USER";
              password-flags = "0";
            };
            vpn-secrets = {
              password = "$VPN_PASSWORD";
            };
          };
        };
      }
    )
  ];
}
