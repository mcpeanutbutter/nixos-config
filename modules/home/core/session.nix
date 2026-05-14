{ config, ... }:
{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, ... }:
      {
        home.username = config.user.username;
        home.homeDirectory = config.user.homeDirectory;

        home.sessionVariables = {
          LC_ALL = "en_US.UTF-8";
        };

        # Expose the zsh derivation under ~/.lib/zsh — handy for scripts that
        # want a reliable absolute path to the user's shell.
        home.file.".lib/zsh".source = pkgs.zsh;

        # Reload systemd user units on activation.
        systemd.user.startServices = "sd-switch";

        # Let home-manager install and manage itself.
        programs.home-manager.enable = true;
      }
    )
  ];
}
