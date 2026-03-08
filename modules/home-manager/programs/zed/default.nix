{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;

    extraPackages = with pkgs.unstable; [
      # Nix
      nixd
      nixfmt

      # Java / JVM
      jdt-language-server
      kotlin-language-server
      metals

      # Python (Astral toolchain)
      ruff
      ty

      # Rust
      rust-analyzer

      # Infrastructure
      terraform-ls
      dockerfile-language-server
      ansible-language-server
      ansible-lint
      helm-ls
      buf

      # Other
      zls
      sqls
    ];

    extensions = [
      # Languages
      "nix"
      "rust"
      "java"
      "kotlin"
      "scala"
      "zig"
      "dockerfile"
      "sql"
      "terraform"
      "proto"
      "ansible"
      "helm"
      "html"
      "toml"

      # Python tooling
      "ruff"
      "ty"
    ];

    userSettings = {
      # === Disable ALL AI ===
      agent.enabled = false;

      # === Disable telemetry ===
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      # === Editor behavior ===
      vim_mode = false;
      load_direnv = "shell_hook";
      format_on_save = "on";
      soft_wrap = "editor_width";
      scroll_beyond_last_line = "one_page";
      show_completions_on_input = true;
      show_completion_documentation = true;
      show_whitespaces = "all";
      bottom_dock_layout = "contained";

      # === IDE-like UI features ===
      inlay_hints = {
        enabled = true;
        show_type_hints = true;
        show_parameter_hints = true;
        show_other_hints = true;
      };

      toolbar = {
        breadcrumbs = true;
        code_actions = false;
        agent_review = true;
        selections_menu = true;
        quick_actions = true;
      };

      title_bar = {
        show_menus = true;
        show_user_menu = true;
        show_sign_in = true;
        show_onboarding_banner = true;
        show_project_items = true;
        show_branch_name = true;
        show_branch_icon = true;
      };

      status_bar = {
        cursor_position_button = true;
        active_language_button = true;
      };

      project_panel.button = true;
      prettier.allowed = true;

      scrollbar.show = "auto";

      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };

      minimap.show = "auto";
      colorize_brackets = true;
      gutter.line_numbers = true;

      git = {
        git_gutter = "tracked_files";
        inline_blame.enabled = true;
      };

      diagnostics = {
        include_warnings = true;
        inline.enabled = true;
      };

      terminal.toolbar.breadcrumbs = false;

      # === Tabs ===
      tab_bar.show = true;
      tabs = {
        show_close_button = "always";
        file_icons = false;
        git_status = true;
      };

      # === Font ===
      buffer_font_features.calt = true;

      # === LSP configuration ===
      # extraPackages puts all LSP binaries on Zed's PATH;
      # Zed auto-detects system-installed servers.
      lsp = {
        nixd.settings.nixd = {
          nixpkgs.expr = "import <nixpkgs> { }";
          formatting.command = [ "nixfmt" ];
        };
      };

      # === Per-language configuration ===
      languages = {
        Nix = {
          language_servers = [ "nixd" ];
          formatter.external = {
            command = "nixfmt";
            arguments = [ ];
          };
          tab_size = 2;
        };
        Python = {
          language_servers = [
            "ruff"
            "ty"
            "!pyright"
          ];
          formatter.language_server.name = "ruff";
          tab_size = 4;
        };
        Rust = {
          language_servers = [ "rust-analyzer" ];
          tab_size = 4;
        };
        Terraform = {
          language_servers = [ "terraform-ls" ];
          tab_size = 2;
        };
        Zig = {
          language_servers = [ "zls" ];
          tab_size = 4;
        };
        Java = {
          language_servers = [ "jdtls" ];
          tab_size = 4;
        };
        Kotlin = {
          language_servers = [ "kotlin-language-server" ];
          tab_size = 4;
        };
        Scala = {
          language_servers = [ "metals" ];
          tab_size = 2;
        };
        SQL = {
          language_servers = [ "sqls" ];
          tab_size = 2;
        };
      };
    };
  };
}
