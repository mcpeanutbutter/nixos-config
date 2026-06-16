{
  flake.modules.homeManager.base.imports = [
    (
      { config, ... }:
      let
        colors = config.lib.stylix.colors;
      in
      {
        programs.fastfetch = {
          enable = true;
          settings = {
            logo = {
              source = "${./fastfetch-logo.txt}";
              type = "file";
              # One stylix base16 accent per lambda (clockwise from top-left).
              color = {
                "1" = "#${colors.base08}"; # red
                "2" = "#${colors.base0B}"; # green
                "3" = "#${colors.base0A}"; # yellow
                "4" = "#${colors.base0D}"; # blue
                "5" = "#${colors.base0E}"; # purple
                "6" = "#${colors.base0C}"; # cyan
              };
            };
            # The HM module always writes a config file, and a config file
            # without a "modules" key renders the logo only. So replicate
            # fastfetch's built-in default module list to keep the usual info.
            modules = [
              "title"
              "separator"
              "os"
              "host"
              "kernel"
              "uptime"
              "packages"
              "shell"
              "display"
              "de"
              "wm"
              "wmtheme"
              "theme"
              "icons"
              "font"
              "cursor"
              "terminal"
              "terminalfont"
              "cpu"
              "gpu"
              "memory"
              "swap"
              "disk"
              "localip"
              "battery"
              "poweradapter"
              "locale"
              "break"
              "colors"
            ];
          };
        };
      }
    )
  ];
}
