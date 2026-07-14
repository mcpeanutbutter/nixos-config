{
  flake.modules.nixos.work.imports = [
    {
      # Workaround for submit-bound license: hold an address in the licensed subnet on loopback so
      # liccap finds a matching interface. Host-scoped /32 — never routed.
      networking.interfaces.lo.ipv4.addresses = [
        {
          address = "192.168.1.56";
          prefixLength = 32;
        }
      ];
    }
  ];
}
