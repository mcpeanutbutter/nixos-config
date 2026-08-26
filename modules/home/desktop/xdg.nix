{
  flake.modules.homeManager.base.imports = [
    (
      { lib, ... }:
      let
        # MIME types that should open in the editor.
        textMimes = [
          "text/plain"
          "text/markdown"
          "text/x-nix"
          "text/x-python"
          "text/x-shellscript"
          "text/x-csrc"
          "text/x-chdr"
          "text/x-c++src"
          "text/x-java"
          "text/x-rust"
          "text/x-go"
          "text/x-lua"
          "text/xml"
          "text/css"
          "text/html"
          "text/javascript"
          "text/x-makefile"
          "text/x-log"
          "application/json"
          "application/x-yaml"
          "application/yaml"
          "application/toml"
          "application/xml"
          "application/x-shellscript"
          "application/javascript"
        ];
      in
      {
        # GNOME Text Editor preferences.
        dconf.settings."org/gnome/TextEditor" = {
          show-line-numbers = true;
          highlight-current-line = true;
          highlight-matching-brackets = true;
          draw-spaces = [
            "space"
            "tab"
            "trailing"
          ];
          indent-style = "space";
          tab-width = lib.hm.gvariant.mkUint32 2;
          indent-width = 2;
          auto-indent = true;
          show-right-margin = true;
          right-margin-position = lib.hm.gvariant.mkUint32 80;
          show-map = true;
          use-system-font = false;
          custom-font = "Maple Mono NF 12";
          line-height = 1.1;
        };

        # Nemo "Open in Terminal" → ghostty.
        dconf.settings."org/cinnamon/desktop/applications/terminal" = {
          exec = "ghostty";
          exec-arg = "-e";
        };

        # Nemo's default thumbnail-limit is 10 MB, which excludes most
        # phone/camera photos. Raise the cap so large local images thumb.
        dconf.settings."org/nemo/preferences" = {
          thumbnail-limit = lib.hm.gvariant.mkUint64 (256 * 1024 * 1024);
        };

        # Register .nix files as a known MIME type (not in the standard DB).
        xdg.dataFile."mime/packages/text-x-nix.xml".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
            <mime-type type="text/x-nix">
              <comment>Nix expression</comment>
              <glob pattern="*.nix"/>
            </mime-type>
          </mime-info>
        '';

        # Zed's own entry runs `zeditor %U`, which drops the file into whichever
        # workspace is already open. This hidden variant passes --new so files
        # opened from the file manager get their own window; the visible Zed
        # launcher entry keeps upstream behaviour.
        xdg.desktopEntries.zed-new = {
          name = "Zed (new window)";
          exec = "zeditor --new %U";
          icon = "zed";
          mimeType = textMimes;
          noDisplay = true;
        };

        # Default application bindings — home-manager manages mimeapps.list as
        # a read-only symlink, so every association we want must be declared here.
        xdg.mimeApps = {
          enable = true;
          defaultApplications =
            let
              loupe = "org.gnome.Loupe.desktop";
            in
            lib.genAttrs textMimes (_: "zed-new.desktop")
            // {
              "inode/directory" = "nemo.desktop";
              "image/png" = loupe;
              "image/jpeg" = loupe;
              "image/gif" = loupe;
              "image/bmp" = loupe;
              "image/tiff" = loupe;
              "image/x-icon" = loupe;
              "image/svg+xml" = loupe;
            };
        };
      }
    )
  ];
}
