{ pkgs, vscode-extensions, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions =
      with (vscode-extensions.forVSCodeVersion pkgs.vscodium.version).vscode-marketplace; [
        # Nix
        mkhl.direnv
        jnoortheen.nix-ide

        # C++
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.cmake-tools

        # Python
        ms-toolsai.jupyter
        ms-pyright.pyright
        ms-python.python
        charliermarsh.ruff

        # Config
        tamasfe.even-better-toml
        gamunu.opentofu
        redhat.ansible
        redhat.vscode-yaml
        samuelcolvin.jinjahtml
        pbkit.vscode-pbkit
        esbenp.prettier-vscode
        inferrinizzard.prettier-sql-vscode

        # Other languages
        ziglang.vscode-zig
        rust-lang.rust-analyzer
        ivandemchenko.roc-lang-unofficial
        golang.go
      ];
    profiles.default.userSettings = {
      "editor.formatOnSave" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.renderWhitespace" = "all";
      "editor.fontLigatures" = true;
      "files.associations" = {
        "*.tftpl" = "jinja-yaml";
      };

      # "editor.fontSize" = 17;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "nix.serverSettings" = {
        "nixd" = {
          "nixpkgs" = {
            "expr" = "import <nixpkgs> { }";
          };
          "formatting" = {
            "command" = [ "nixfmt" ];
          };
          "options" = {
            # nixpkgs = "${pkgs.path}";
          };
        };
      };
      "redhat.telemetry.enabled" = false;
      # "terminal.integrated.fontSize" = 17;
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "workbench.editor.tabSizing" = "shrink";
      "zig.zls.enabled" = "on";
      "C_Cpp.default.configurationProvider" = "ms-vscode.cmake-tools";
    };
  };
}
