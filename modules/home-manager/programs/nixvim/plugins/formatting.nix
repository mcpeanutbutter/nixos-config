{ ... }:
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
        terraform = [ "terraform_fmt" ];
        tf = [ "terraform_fmt" ];
        tofu = [ "tofu_fmt" ];
        python = [ "black" ];
      };
      format_on_save = {
        timeout_ms = 500;
        lsp_format = "fallback";
      };
    };
  };
}
