{ ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      clangd.enable = true;
      docker_compose_language_service.enable = true;
      dockerls.enable = true;
      helm_ls.enable = true;
      kotlin_language_server.enable = true;
      lua_ls.enable = true;
      nixd.enable = true;
      pyright.enable = true;
      taplo.enable = true;
      tinymist.enable = true;
      yamlls.enable = true;
      terraformls = {
        # Workaround for OpenTofu
        enable = true;
        filetypes = [
          "tf"
          "terraform"
          "terraform-vars"
          "tfvars"
          "tofu"
        ];
      };
    };
  };
}
