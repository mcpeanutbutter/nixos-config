{ pkgs, config, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.zed-editor);
    extensions = [
      "html"
      "nix"
      "proto"
      "toml"
      # "Material Theme"
    ];
    userSettings = {
      features = {
        copilot = false;
      };
      telemetry = {
        metrics = true;
      };
      tabs.always_show_close_button = true;
      vim_mode = false;
      load_direnv = "shell_hook";
      format_on_save = "on";

      assistant = {
        enabled = true;
        version = "2";
        default_model = {
          provider = "ollama";
          model = "deepseek-r1:1.5b";
        };
      };

      language_models.ollama = {
        api_url = "http://localhost:11434";
        available_models = [
          {
            name = "deepseek-r1:1.5b";
            display_name = "DeepSeek R1 1.5B";
            # max_tokens = 32768;
          }
        ];
      };
    };
  };
}
