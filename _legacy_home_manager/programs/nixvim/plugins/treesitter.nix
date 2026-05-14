{ ... }:
{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      nixvimInjections = true;
      folding.enable = true;
      settings = {
        indent.enable = true;
        highlight.enable = true;
      };
      languageRegister = {
        hcl = [
          "tf"
          "terraform"
          "tofu"
        ];
      };
    };

    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "af" = {
              query = "@function.outer";
              desc = "Select outer function";
            };
            "if" = {
              query = "@function.inner";
              desc = "Select inner function";
            };
            "ac" = {
              query = "@class.outer";
              desc = "Select outer class";
            };
            "ic" = {
              query = "@class.inner";
              desc = "Select inner class";
            };
            "as" = {
              query = "@local.scope";
              query_group = "locals";
              desc = "Select local scope";
            };
          };
        };
        swap = {
          enable = true;
          swap_next = {
            "<leader>a" = "@parameter.inner";
          };
          swap_previous = {
            "<leader>A" = "@parameter.inner";
          };
        };
        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]m" = "@function.outer";
            "]p" = "@parameter.outer";
          };
          goto_next_end = {
            "]M" = "@function.outer";
            "]P" = "@parameter.outer";
          };
          goto_previous_start = {
            "[m" = "@function.outer";
            "[p" = "@parameter.outer";
          };
          goto_previous_end = {
            "[M" = "@function.outer";
            "[P" = "@parameter.outer";
          };
        };
      };
    };

    # treesitter-context = {
    #   enable = true;
    #   settings = {
    #     max_lines = 3;
    #   };
    # };

    ts-context-commentstring.enable = true;
  };
}
