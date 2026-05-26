{ inputs, ... }:
{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, ... }:
      let
        # Read marketplace extensions directly from the flake input — replaces
        # the legacy `vscode-extensions` extraSpecialArg.
        vsx = inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system};
      in
      {
        programs.vscode = {
          enable = true;
          package = pkgs.unstable.vscodium;
          profiles.default.extensions =
            # TODO: restore forVSCodeVersion filtering once nix-vscode-extensions handles
            # non-semver versions (currently breaks on vscodium 1.112.01907).
            # with (vsx.forVSCodeVersion pkgs.unstable.vscodium.version).vscode-marketplace; [
            with vsx.vscode-marketplace; [
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
              myriad-dreamin.tinymist
            ];

          profiles.default.userSettings = {
            "editor.formatOnSave" = true;
            "editor.inlineSuggest.enabled" = true;
            "editor.renderWhitespace" = "all";
            "editor.fontLigatures" = true;
            "files.associations"."*.tftpl" = "jinja-yaml";

            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
            "nix.serverSettings".nixd = {
              nixpkgs.expr = "import <nixpkgs> { }";
              formatting.command = [ "nixfmt" ];
              options = { };
            };
            "redhat.telemetry.enabled" = false;
            "terminal.integrated.defaultProfile.linux" = "zsh";
            "workbench.editor.tabSizing" = "shrink";
            "zig.zls.enabled" = "on";
            "C_Cpp.default.configurationProvider" = "ms-vscode.cmake-tools";
          };
        };
      }
    )
  ];
}
