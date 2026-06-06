{
  flake.modules.homeManager.noctalia.imports = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        # After a `nixos-rebuild switch`, niri live-reloads its config and the
        # Mod+D / Mod+X / Mod+Alt+X binds now invoke the *new* noctalia-shell
        # wrapper, whose QS_CONFIG_PATH points at the new store path. The
        # still-running daemon registered under the *old* path, so the IPC
        # calls fail ("No running instances") until noctalia is restarted —
        # only the bar keeps working because it *is* the running instance.
        #
        # Upstream deprecates the systemd service and recommends the compositor
        # spawn-at-startup we already use, so restart the shell here instead of
        # switching launch mechanisms. We only act when a niri socket exists
        # (i.e. inside a live graphical session) — a no-op on boot/headless
        # activation. The relaunch goes through `niri msg action spawn` so the
        # new process inherits the session environment, and via the absolute
        # new-generation path so we don't re-exec the stale binary from the
        # session's old PATH. The kill runs here (not inside the spawned
        # helper) so its `-f` pattern can't match the helper's own cmdline.
        home.activation.restartNoctalia = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          runtimeDir="''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}"
          sock="$(${pkgs.coreutils}/bin/ls -t "$runtimeDir"/niri.*.sock 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)"
          if [ -n "$sock" ]; then
            $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -f bin/quickshell 2>/dev/null || true
            $DRY_RUN_CMD ${pkgs.coreutils}/bin/sleep 0.3
            $DRY_RUN_CMD env NIRI_SOCKET="$sock" ${lib.getExe pkgs.niri} msg action spawn -- ${lib.getExe config.programs.noctalia-shell.package}
          fi
        '';
      }
    )
  ];
}
