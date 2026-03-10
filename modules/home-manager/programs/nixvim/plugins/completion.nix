{ ... }:
{
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap = {
          preset = "none";
          "<C-y>" = [
            "select_and_accept"
          ];
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<C-space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-e>" = [
            "hide"
          ];
          "<C-b>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-f>" = [
            "scroll_documentation_down"
            "fallback"
          ];
          "<C-k>" = [
            "show_signature"
            "hide_signature"
            "fallback"
          ];
          "<Tab>" = [
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "snippet_backward"
            "fallback"
          ];
        };
        appearance = {
          nerd_font_variant = "mono";
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          ghost_text.enabled = true;
        };
        signature = {
          enabled = true;
        };
        snippets = {
          preset = "luasnip";
        };
      };
    };

    luasnip.enable = true;
  };
}
