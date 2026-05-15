{
  flake.modules.homeManager.base.imports = [
    (
      { lib, ... }:
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

        # Default application bindings — home-manager manages mimeapps.list as
        # a read-only symlink, so every association we want must be declared here.
        xdg.mimeApps = {
          enable = true;
          defaultApplications =
            let
              editor = "org.gnome.TextEditor.desktop";
              loupe = "org.gnome.Loupe.desktop";
            in
            {
              "inode/directory" = "nemo.desktop";
              "text/plain" = editor;
              "text/markdown" = editor;
              "text/x-nix" = editor;
              "text/x-python" = editor;
              "text/x-shellscript" = editor;
              "text/x-csrc" = editor;
              "text/x-chdr" = editor;
              "text/x-c++src" = editor;
              "text/x-java" = editor;
              "text/x-rust" = editor;
              "text/x-go" = editor;
              "text/x-lua" = editor;
              "text/xml" = editor;
              "text/css" = editor;
              "text/html" = editor;
              "text/javascript" = editor;
              "text/x-makefile" = editor;
              "text/x-log" = editor;
              "application/json" = editor;
              "application/x-yaml" = editor;
              "application/yaml" = editor;
              "application/toml" = editor;
              "application/xml" = editor;
              "application/x-shellscript" = editor;
              "application/javascript" = editor;
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
