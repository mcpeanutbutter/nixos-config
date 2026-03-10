{ pkgs, ... }:
{
  programs.nixvim = {
    plugins = {
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
        settings = {
          notification = {
            window = {
              winblend = 0;
            };
          };
        };
      };

      todo-comments = {
        enable = true;
        settings = {
          signs = true;
        };
      };

      web-devicons.enable = true;
    };

    # extraPlugins = with pkgs.vimPlugins; [
    #   eyeliner-nvim
    #   statuscol-nvim
    # ];

    # extraConfigLua = ''
    #   -- Eyeliner: highlight unique chars for f/F/t/T
    #   require('eyeliner').setup({
    #     highlight_on_key = true,
    #     dim = true,
    #   })
    #
    #   -- Statuscol: status column with line numbers and signs
    #   local builtin = require('statuscol.builtin')
    #   require('statuscol').setup({
    #     relculright = true,
    #     segments = {
    #       { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
    #       { text = { '%s' }, click = 'v:lua.ScSa' },
    #       { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
    #     },
    #   })
    # '';
  };
}
