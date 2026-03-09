{
  pkgs,
  lib,
  ...
}:
let
  # Wallpaper list — to add/remove wallpapers, edit this list. Schedules auto-adjust.
  # Use `nix-prefetch-url --name <clean-name> <url>` to get sha256 for new entries.
  # The `name` field must be a valid Nix store name (no spaces or special characters).
  wallpapers = [
    {
      name = "bliss";
      url = "https://ia601200.us.archive.org/11/items/theoriginalfilesofsomewindowswallpapers/bliss%20600dpi.jpg";
      sha256 = "0xm27x6dnzns8dca08w2y4wjr35kqf90lbnk57hbkqk4x0w8fv6z";
    }
    {
      name = "catalina";
      url = "https://512pixels.net/downloads/macos-wallpapers/10-15-Day.jpg";
      sha256 = "0j8mhpdy0dz141d6s2a242kwrhqjlnjcrv7ks2c3x33ii7fs4hyr";
    }
    {
      name = "bigsur";
      url = "https://512pixels.net/downloads/macos-wallpapers/11-0-Day.jpg";
      sha256 = "17bmm234nj3xikr7q76c35mqxnc0mncpfk7hksj0zn8x397h0a6j";
    }
    {
      name = "mojave";
      url = "https://512pixels.net/downloads/macos-wallpapers-6k/10-14-Day-6k.jpg";
      sha256 = "0fc71x1hwsng647qfl2s6yxzwc0rlcrlpz3x81vmxd6dpbs6y0kq";
    }
  ];

  n = builtins.length wallpapers;

  # Fetch a wallpaper, using `name` to ensure a clean Nix store path
  fetchWallpaper =
    wp:
    pkgs.fetchurl {
      inherit (wp) url sha256;
      name = "${wp.name}.jpg";
    };

  # Generate a night + optionally blurred version of a wallpaper for the overview backdrop.
  # Night transform: reduce red/green, boost blue, darken + desaturate.
  blurSigma = 25; # Gaussian blur sigma for overview backdrop (0 = no blur)
  mkBackdropWallpaper =
    wp:
    let
      src = fetchWallpaper wp;
    in
    pkgs.runCommand "backdrop-${wp.name}.jpg" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
      magick ${src} \
        -channel R -evaluate multiply 0.4 \
        -channel G -evaluate multiply 0.5 \
        -channel B -evaluate multiply 0.8 \
        +channel -modulate 50,40 \
        ${lib.optionalString (blurSigma != 0) "-blur 0x${toString blurSigma}"} \
        $out
    '';

  # Zero-padded two-digit hour string
  pad = i: lib.fixedWidthString 2 "0" (toString i);

  # Wallpaper setter script for a given wallpaper entry
  mkWallpaperScript =
    wp:
    let
      day = fetchWallpaper wp;
      backdrop = mkBackdropWallpaper wp;
    in
    pkgs.writeShellScript "set-wallpaper-${wp.name}" ''
      ${pkgs.swww}/bin/swww img ${day} --namespace desktop --transition-type simple --transition-duration 2
      ${pkgs.swww}/bin/swww img ${backdrop} --namespace backdrop --transition-type simple --transition-duration 2
    '';

  # Generate indexed wallpaper entries: [ { i = 0; wp = { name = ...; }; } ... ]
  indexed = lib.imap0 (i: wp: { inherit i wp; }) wallpapers;

  # First wallpaper (used as initial wallpaper on daemon start)
  first = builtins.head wallpapers;

  # Generate swww-set-* services and timers from the wallpaper list
  rotationServices = lib.listToAttrs (
    map (
      { i, wp }:
      lib.nameValuePair "swww-set-${wp.name}" {
        Unit = {
          Description = "Set ${wp.name} wallpapers";
          After = [
            "swww-desktop.service"
            "swww-backdrop.service"
          ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${mkWallpaperScript wp}";
        };
      }
    ) indexed
  );

  rotationTimers = lib.listToAttrs (
    map (
      { i, wp }:
      lib.nameValuePair "swww-set-${wp.name}" {
        Unit.Description = "Rotate to ${wp.name} wallpapers";
        Timer = {
          OnCalendar = "*-*-* ${pad i}/${toString n}:00:00";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      }
    ) indexed
  );
in
{
  home.packages = [ pkgs.swww ];

  systemd.user.services = {
    swww-desktop = {
      Unit = {
        Description = "Wallpaper daemon for desktop (swww)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swww}/bin/swww-daemon --namespace desktop";
        ExecStartPost = "${pkgs.swww}/bin/swww img ${fetchWallpaper first} --namespace desktop";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    swww-backdrop = {
      Unit = {
        Description = "Wallpaper daemon for backdrop (swww)";
        After = [
          "graphical-session.target"
          "swww-desktop.service"
        ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swww}/bin/swww-daemon --namespace backdrop";
        ExecStartPost = "${pkgs.swww}/bin/swww img ${mkBackdropWallpaper first} --namespace backdrop";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  }
  // rotationServices;

  systemd.user.timers = rotationTimers;
}
