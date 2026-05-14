{
  flake.modules.homeManager.base.programs.nixvim.plugins = {
    which-key = {
      enable = true;
      settings = {
        preset = "helix";
        spec = [
          {
            __unkeyed-1 = "<leader>h";
            group = "Git Hunk";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "Search";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Toggle";
          }
          {
            __unkeyed-1 = "gr";
            group = "LSP";
          }
        ];
      };
    };

    fidget = {
      enable = true;
      settings.notification.window.winblend = 0;
    };

    todo-comments = {
      enable = true;
      settings.signs = true;
    };

    web-devicons.enable = true;
  };
}
