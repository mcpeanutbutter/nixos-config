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
        # JetBrains' Kotlin extension chmod +x's its bundled intellij-server
        # launcher at activation — EROFS on the read-only store, so the LSP
        # never starts. The store copy is already executable and the extension
        # has no external-server-path setting, so neuter the lone chmodSync
        # call. --replace-fail makes a version bump that moves the code a
        # loud build error instead of a silent regression.
        kotlin-server = marketplace.jetbrains.kotlin-server.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            substituteInPlace "$out/share/vscode/extensions/jetbrains.kotlin-server/out/dist/extension.js" \
              --replace-fail '(0,external_fs_.chmodSync)(e,493)' '0'
          '';
        });
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
            ms-python.python
            charliermarsh.ruff
            # ty (Astral) is the Python language server — replaces ms-python's bundled
            # Jedi (disabled via python.languageServer below) and the standalone Pyright.
            # Unlike Jedi it speaks the LSP notebook protocol, so the Interactive Window
            # stops throwing "Error in server: KeyError: 'vscode-notebook-cell:...'".
            astral-sh.ty

            # Config
            tamasfe.even-better-toml
            gamunu.opentofu
            redhat.ansible
            redhat.vscode-yaml
            redhat.vscode-xml
            samuelcolvin.jinjahtml
            pbkit.vscode-pbkit
            esbenp.prettier-vscode
            inferrinizzard.prettier-sql-vscode

            # CI / API tooling
            gitlab.gitlab-workflow
            # attr starts with a digit, so the `with marketplace` shorthand can't reach it
            marketplace."42crunch".vscode-openapi

            # Java / Kotlin / Scala (JVM)
            kotlin-server # patched jetbrains.kotlin-server, see let-binding above
            oracle.oracle-java
            vscjava.vscode-gradle
            vscjava.vscode-maven
            scalameta.metals

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

            # Python: ty (Astral) is the sole language server. Disable ms-python's
            # bundled Jedi — it can't handle Interactive-Window notebook cells and
            # threw a KeyError per cell. Point ty at the nixpkgs binary; the
            # extension's bundled ty is ancient (0.0.1-alpha.34) and FHS-linked.
            "python.languageServer" = "None";
            "ty.path" = [ "${pkgs.unstable.ty}/bin/ty" ];

            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
            "nix.serverSettings".nixd = {
              nixpkgs.expr = "import <nixpkgs> { }";
              formatting.command = [ "nixfmt" ];
              options = { };
            };
            # GitLab Duo (AI) off — the Workflow extension is here for CI lint + MRs.
            "gitlab.duoCodeSuggestions.enabled" = false;
            "gitlab.duoChat.enabled" = false;
            "gitlab.duoAgentPlatform.enabled" = false;
            "redhat.telemetry.enabled" = false;
            # Extensions dir is immutable (mutableExtensionsDir = false); stop VSCodium
            # from trying to auto-update against it and emitting failure toasts.
            "extensions.autoUpdate" = false;
            "extensions.autoCheckUpdates" = false;
            "terminal.integrated.defaultProfile.linux" = "zsh";
            "workbench.editor.tabSizing" = "shrink";
            "zig.zls.enabled" = "on";
            "C_Cpp.default.configurationProvider" = "ms-vscode.cmake-tools";

            # git
            "git.blame.editorDecoration.enabled" = false;
          };
        };
      }
    )
  ];
}
