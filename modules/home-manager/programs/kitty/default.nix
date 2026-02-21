{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.kitty);
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = "no";
      visual_bell_duration = "0.2";
      remember_window_size = false;
      initial_window_width = 800;
      initial_window_height = 600;
      shell = "zsh";
      single_window_padding_width = 4;
      window_padding_width = 4;
    };
  };
}
