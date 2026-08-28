{
  flake.modules.homeManager.base.imports = [
    (
      { ... }:
      {
        programs.niri.settings = {
          # First named workspace. Unlike a dynamic workspace it always exists,
          # even while empty, so Teams and Obsidian always have a home to open
          # into. The attribute key is pure sort order — it never reaches the
          # KDL, only the name does — so ordering a second named workspace later
          # is a free rename of both keys.
          #
          # open-on-output stays unset here because this file is shared by all
          # three hosts and only amateria has a second monitor. Niri does not
          # default it to the external panel — left unpinned it put hub on
          # eDP-1 — so amateria pins it in modules/hosts/amateria/displays.nix,
          # which already owns that host's output config.
          workspaces.hub = { };

          # Cumulative with the matches-less rounded-corners rule in enable.nix:
          # niri applies every matching rule in order and a later rule overrides
          # only the fields it sets, so these windows keep their corner radius.
          window-rules = [
            {
              matches = [
                # Teams is a Brave --app window (xdg.desktopEntries.microsoft-teams
                # in modules/home/programs/brave.nix). Chromium derives the app-id
                # from the --app URL plus the profile dir, and ignores --class for
                # app windows even on a cold start, so the URL is the only handle
                # there is. Anchored on the host only, to survive a profile change;
                # re-check with `niri msg pick-window` if Teams stops landing here.
                { app-id = "^brave-teams\\.cloud\\.microsoft"; }
                { app-id = "^md\\.Obsidian$"; }
              ];
              open-on-workspace = "hub";
            }
          ];
        };
      }
    )
  ];
}
