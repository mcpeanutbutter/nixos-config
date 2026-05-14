{ ... }:
{
  programs.nixvim = {
    plugins = {
      nvim-surround.enable = true;
      guess-indent.enable = true;
      mini = {
        enable = true;
        modules.ai = {
          n_lines = 500;
        };
      };
    };
  };
}
