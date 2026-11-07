let
  bookmarksSecret = "qutebrowser/bookmarks";
in
{
  flake.modules.homeManager.base.imports = [
    (
      { config, ... }:
      {
        # Managed bookmarks live in sops (same `url title` line format as
        # qutebrowser's bookmarks/urls). HM has no bookmarks option, and a
        # store symlink would make bookmarks/urls read-only, so config.py
        # merges at startup instead: bookmarks/urls stays the local, writable
        # list (:bookmark-add works), the sops set is laid on top, and
        # managed-bookmarks remembers the last sops set so entries removed
        # from sops get dropped rather than lingering as "local".
        sops.secrets.${bookmarksSecret} = { };

        programs.qutebrowser = {
          enable = true;
          extraConfig = ''
            import os
            import pathlib


            def _merge_managed_bookmarks(managed_file, urls_file, state_file):
                def read(path):
                    try:
                        return [l for l in path.read_text().splitlines() if l.strip()]
                    except FileNotFoundError:
                        return []

                def url(line):
                    return line.split(maxsplit=1)[0]

                # sops-nix hasn't decrypted yet: leave everything as is.
                if not managed_file.exists():
                    return
                managed = read(managed_file)
                drop = {url(l) for l in read(state_file) + managed}
                local = [l for l in read(urls_file) if url(l) not in drop]

                urls_file.parent.mkdir(parents=True, exist_ok=True)
                tmp = urls_file.with_suffix(".tmp")
                tmp.write_text("".join(l + "\n" for l in managed + local))
                os.replace(tmp, urls_file)
                state_file.write_text("".join(l + "\n" for l in managed))


            _merge_managed_bookmarks(
                pathlib.Path("${config.sops.secrets.${bookmarksSecret}.path}"),
                config.configdir / "bookmarks" / "urls",
                config.datadir / "managed-bookmarks",
            )
          '';
        };
      }
    )
  ];
}
