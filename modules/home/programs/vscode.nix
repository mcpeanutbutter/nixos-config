{ inputs, ... }:
{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, lib, ... }:
      let
        codium = pkgs.unstable.vscodium;
        # Read marketplace extensions directly from the flake input — replaces
        # the legacy `vscode-extensions` extraSpecialArg.
        vsx = inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system};
        # nix-vscode-extensions' forVSCodeVersion uses a strict SemVer parser that rejects
        # VSCodium's zero-padded patch field (e.g. "1.121.03429"). Normalise each numeric
        # component; toIntBase10 tolerates the leading zeros (plain toInt throws on octal
        # ambiguity, bare forVSCodeVersion throws "Invalid SemVer").
        codiumVersion = lib.concatMapStringsSep "." (c: toString (lib.toIntBase10 c)) (
          lib.splitString "." codium.version
        );
        marketplace = (vsx.forVSCodeVersion codiumVersion).vscode-marketplace;
      in
      {
        programs.vscodium = {
          enable = true;
          package = codium;
          # Seal the extensions dir to the declared set: with the home-manager default
          # (true), VSCodium keeps the dir writable and silently auto-installs/updates
          # its own copies that shadow the declarative symlinks (drift). false makes HM
          # own the dir as one immutable store symlink, so the editor runs exactly this.
          mutableExtensionsDir = false;
          profiles.default.extensions = with marketplace; [
            # Nix
            mkhl.direnv
            jnoortheen.nix-ide

            # C++
            llvm-vs-code-extensions.vscode-clangd
            ms-vscode.cmake-tools

            # Python
            ms-toolsai.jupyter
            # Jupyter is an extension pack; nix-vscode-extensions does not auto-resolve
            # pack members, so list them explicitly (renderers is required for output).
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            ms-toolsai.vscode-jupyter-cell-tags
            ms-toolsai.vscode-jupyter-slideshow
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
            # Extensions dir is immutable (mutableExtensionsDir = false); stop VSCodium
            # from trying to auto-update against it and emitting failure toasts.
            "extensions.autoUpdate" = false;
            "extensions.autoCheckUpdates" = false;
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
