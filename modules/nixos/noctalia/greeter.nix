{ inputs, config, ... }:
{
  flake.modules.nixos.noctalia.imports = [
    inputs.noctalia-greeter.nixosModules.default
    {
      # The greeter shows the AccountsService IconFile, which defaults to this
      # path (it can't read ~/.face: the greeter user has no access to $HOME).
      # L+ replaces whatever an earlier desktop left there; the shell's
      # avatar_path (modules/home/noctalia/enable.nix) points at the same file.
      systemd.tmpfiles.rules = [
        "L+ /var/lib/AccountsService/icons/${config.user.username} - - - - ${./face.png}"
      ];

      # Enables greetd with noctalia-greeter-session as the default session
      # and accounts-daemon for user lookup.
      programs.noctalia-greeter = {
        enable = true;
        # Lets the shell's greeter_sync apply wallpaper/palette via polkit
        # without a password prompt.
        passwordless-sync-users = [ config.user.username ];
        settings = {
          user.default = config.user.username;
          keyboard = {
            layout = "us";
            variant = "altgr-intl";
          };
        };
      };
    }
  ];
}
