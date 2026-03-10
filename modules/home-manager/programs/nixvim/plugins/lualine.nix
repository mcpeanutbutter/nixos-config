{ ... }:
{
  programs.nixvim.plugins = {
    navic = {
      enable = true;
      settings = {
        lsp.auto_attach = false; # We attach manually in LspAttach autocommand
      };
    };

    lualine = {
      enable = true;
      settings = {
        options = {
          globalstatus = true;
          theme = "auto";
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [
            "branch"
            "diff"
            "diagnostics"
          ];
          lualine_c = [
            {
              __unkeyed-1 = "navic";
              navic_opts.__raw = "nil";
            }
          ];
          lualine_x = [
            {
              __unkeyed-1.__raw = ''
                function()
                  local reg = vim.fn.reg_recording()
                  if reg ~= "" then return "@" .. reg end
                  reg = vim.fn.reg_executing()
                  if reg ~= "" then return "@" .. reg end
                  return ""
                end
              '';
            }
            "encoding"
            "fileformat"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
        winbar = {
          lualine_a = [ ];
          lualine_b = [ ];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1; # Relative path
              newfile_status = true;
            }
          ];
          lualine_x = [ ];
          lualine_y = [ ];
          lualine_z = [ ];
        };
        inactive_winbar = {
          lualine_a = [ ];
          lualine_b = [ ];
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1;
              newfile_status = true;
            }
          ];
          lualine_x = [ ];
          lualine_y = [ ];
          lualine_z = [ ];
        };
        extensions = [
          "fugitive"
          "fzf"
          "quickfix"
        ];
      };
    };
  };
}
