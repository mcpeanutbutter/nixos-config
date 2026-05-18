{
  flake.modules.nixos.base = {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # Streams follow the current default sink instead of being re-pinned
      # to whichever device they last played on — otherwise apps silently
      # ignore default-sink changes. Per-app volume/mute memory is kept
      # (node.stream.restore-props defaults to true).
      wireplumber.extraConfig."51-no-target-restore" = {
        "wireplumber.settings"."node.stream.restore-target" = false;
      };
    };
    # Focusrite Scarlett interfaces sometimes vanish after resume when USB
    # autosuspend kicks in. Keep them powered.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", ATTR{power/control}="on"
    '';
  };
}
