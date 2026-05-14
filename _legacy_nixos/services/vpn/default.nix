{ config, pkgs, ... }:
{
  # FortiSSLVPN NM plugin (uses openfortivpn backend, supports declarative credentials)
  networking.networkmanager.plugins = [ pkgs.networkmanager-fortisslvpn ];

  # Sops secrets for VPN credentials
  sops.secrets."vpn/server" = { };
  sops.secrets."vpn/username" = { };
  sops.secrets."vpn/password" = { };

  # Combine secrets into env file for NM ensureProfiles
  sops.templates."vpn-env".content = ''
    VPN_SERVER=${config.sops.placeholder."vpn/server"}
    VPN_USER=${config.sops.placeholder."vpn/username"}
    VPN_PASSWORD=${config.sops.placeholder."vpn/password"}
  '';

  # Declarative NM VPN profile
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
