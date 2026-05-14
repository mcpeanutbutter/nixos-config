{
  flake.modules.nixos.base = {
    services.printing = {
      enable = true;
      # Don't browse other CUPS servers — printers are discovered via Avahi.
      extraConf = ''
        BrowseRemoteProtocols none
      '';
    };

    # mDNS/DNS-SD for network printer auto-discovery.
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
