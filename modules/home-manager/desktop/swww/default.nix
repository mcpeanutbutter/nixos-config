{
  pkgs,
  lib,
  ...
}:
let
  # Wallpaper Set 0: macOS Mojave 10.14 (Day/Night)
  mojaveDay = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers-6k/10-14-Day-6k.jpg";
    sha256 = "0fc71x1hwsng647qfl2s6yxzwc0rlcrlpz3x81vmxd6dpbs6y0kq";
  };

  mojaveNight = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers-6k/10-14-Night-6k.jpg";
    sha256 = "09vgyvrjbi5zdrgifdq8zpp9qb9yf70g1npc0ldz3j5kbydnq4fn";
  };

  # Wallpaper Set 1: macOS Catalina 10.15 (Day/Night)
  catalinaDay = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers/10-15-Day.jpg";
    sha256 = "0j8mhpdy0dz141d6s2a242kwrhqjlnjcrv7ks2c3x33ii7fs4hyr";
  };

  catalinaNight = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers/10-15-Night.jpg";
    sha256 = "08cd0lacb2l0kal1zvxk7xhignqvhwdznwgqmsxy2iw7kzy12yfa";
  };

  # Wallpaper Set 2: macOS Big Sur 11.0 (Day/Night)
  bigSurDay = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers/11-0-Day.jpg";
    sha256 = "17bmm234nj3xikr7q76c35mqxnc0mncpfk7hksj0zn8x397h0a6j";
  };

  bigSurNight = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers/11-0-Night.jpg";
    sha256 = "0h7mhf7yr0n6b0g6iklbvkshgxpxyy7lldyf5wxvzggff26r7hbw";
  };

  # Wallpaper Set 3: Lake Tahoe Beach (Day/Night)
  tahoeDay = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers-6k/26-Tahoe-Beach-Day.png";
    sha256 = "0nj9w3b3ayl3j31wnf339z97x9aywk1aq809flp6wqhjkgy8cfjc";
  };

  tahoeNight = pkgs.fetchurl {
    url = "https://512pixels.net/downloads/macos-wallpapers-6k/26-Tahoe-Beach-Night.png";
    sha256 = "1frivc1xv35cada7lbqiswbgracsp6mkc37dv2zklgcg0f2x0w4f";
  };

  # Function to create a wallpaper setter script
  mkWallpaperScript =
    name: dayWallpaper: nightWallpaper:
    pkgs.writeShellScript "set-wallpaper-${name}" ''
      ${pkgs.swww}/bin/swww img ${dayWallpaper} --namespace desktop --transition-type any --transition-duration 2
      ${pkgs.swww}/bin/swww img ${nightWallpaper} --namespace backdrop --transition-type any --transition-duration 2
    '';

  # Wallpaper sets configuration
  wallpaperSets = {
    mojave = {
      day = mojaveDay;
      night = mojaveNight;
      schedule = "00/4:00:00"; # 0:00, 4:00, 8:00, 12:00, 16:00, 20:00
    };
    catalina = {
      day = catalinaDay;
      night = catalinaNight;
      schedule = "01/4:00:00"; # 1:00, 5:00, 9:00, 13:00, 17:00, 21:00
    };
    bigsur = {
      day = bigSurDay;
      night = bigSurNight;
      schedule = "02/4:00:00"; # 2:00, 6:00, 10:00, 14:00, 18:00, 22:00
    };
    tahoe = {
      day = tahoeDay;
      night = tahoeNight;
      schedule = "03/4:00:00"; # 3:00, 7:00, 11:00, 15:00, 19:00, 23:00
    };
  };

  # Function to create a systemd timer that directly runs the wallpaper script
  mkWallpaperTimer = name: set: {
    Unit = {
      Description = "Rotate to ${name} wallpapers";
    };
    Timer = {
      OnCalendar = set.schedule;
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Function to create the service that the timer triggers
  mkWallpaperService = name: set: {
    Unit = {
      Description = "Set ${name} wallpapers";
      After = [
        "swww-desktop.service"
        "swww-backdrop.service"
      ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${mkWallpaperScript name set.day set.night}";
    };
  };
in
{
  # Install swww package
  home.packages = [ pkgs.swww ];

  # Systemd services: daemon services + wallpaper rotation services
  systemd.user.services = {
    # Desktop wallpaper daemon (regular workspace background)
    swww-desktop = {
      Unit = {
        Description = "Wallpaper daemon for desktop (swww)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swww}/bin/swww-daemon --namespace desktop";
        ExecStartPost = "${pkgs.swww}/bin/swww img ${bigSurDay} --namespace desktop";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Backdrop wallpaper daemon (overview background)
    swww-backdrop = {
      Unit = {
        Description = "Wallpaper daemon for backdrop (swww)";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swww}/bin/swww-daemon --namespace backdrop";
        ExecStartPost = "${pkgs.swww}/bin/swww img ${bigSurNight} --namespace backdrop";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  }
  // lib.mapAttrs' (
    name: set:
    # Generate rotation services for each wallpaper set
    lib.nameValuePair "swww-set-${name}" (mkWallpaperService name set)
  ) wallpaperSets;

  # Generate timers for each wallpaper set
  systemd.user.timers = lib.mapAttrs' (
    name: set: lib.nameValuePair "swww-set-${name}" (mkWallpaperTimer name set)
  ) wallpaperSets;
}
