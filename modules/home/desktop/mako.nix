{
  flake.modules.homeManager.base.services.mako = {
    enable = true;

    settings = {
      default-timeout = 5000; # 5s default
      layer = "overlay";

      "urgency=low".default-timeout = 3000;

      "urgency=high" = {
        default-timeout = 0;
        ignore-timeout = 1;
      };
    };
  };
}
