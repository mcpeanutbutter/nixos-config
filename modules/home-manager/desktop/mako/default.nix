{ config, pkgs, ... }:
{
  # Enable mako notification daemon
  # Stylix will automatically theme it
  services.mako = {
    enable = true;

    # Just configure behavior, let stylix handle appearance
    defaultTimeout = 5000; # 5 seconds
    layer = "overlay";

    extraConfig = ''
      [urgency=low]
      default-timeout=3000

      [urgency=high]
      default-timeout=0
      ignore-timeout=1
    '';
  };
}
