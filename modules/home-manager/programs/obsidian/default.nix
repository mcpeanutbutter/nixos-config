{ config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  # Disable Stylix auto-theming for Obsidian — we handle everything ourselves
  stylix.targets.obsidian.enable = false;

  programs.obsidian = {
    enable = true;
    vaults.obsidian = {
      target = "Documents/obsidian";
      settings.cssSnippets = [
        {
          name = "Material Darker";
          text = ''
            .theme-dark {
              /* Base colors */
              --color-base-00: #${colors.base00};
              --color-base-05: #${colors.base00};
              --color-base-10: #${colors.base00};
              --color-base-20: #${colors.base01};
              --color-base-25: #${colors.base01};
              --color-base-30: #${colors.base02};
              --color-base-35: #${colors.base02};
              --color-base-40: #${colors.base03};
              --color-base-50: #${colors.base03};
              --color-base-60: #${colors.base04};
              --color-base-70: #${colors.base04};
              --color-base-100: #${colors.base05};

              --color-accent: #${colors.base0E};
              --color-accent-1: #${colors.base0E};
            }

            /* Workspace */
            .workspace {
              color: #${colors.base05};
              background-color: #${colors.base00};
            }

            .workspace-tabs,
            .workspace-tab-header,
            .workspace-leaf {
              color: #${colors.base05};
              background-color: #${colors.base00};
            }

            .workspace-tab-header-inner {
              color: #${colors.base02};
            }

            /* View header */
            .view-header {
              background-color: #${colors.base00};
              color: #${colors.base05};
              border-bottom: 1px solid #${colors.base01};
            }

            .view-header-title {
              color: #${colors.base05};
            }

            .view-header-title-container:after {
              background: none;
            }

            .view-content {
              background-color: #${colors.base00};
              color: #${colors.base05};
            }

            .view-action {
              color: #${colors.base05};
            }

            /* Navigation */
            .nav-folder-title, .nav-file-title {
              background-color: #${colors.base00};
              color: #${colors.base05};
            }

            .nav-action-button {
              color: #${colors.base05};
            }

            /* Markdown headers */
            .cm-header-1, .markdown-preview-view h1 { color: #${colors.base0A}; }
            .cm-header-2, .markdown-preview-view h2 { color: #${colors.base0B}; }
            .cm-header-3, .markdown-preview-view h3 { color: #${colors.base0C}; }
            .cm-header-4, .markdown-preview-view h4 { color: #${colors.base0D}; }
            .cm-header-5, .markdown-preview-view h5 { color: #${colors.base0E}; }
            .cm-header-6, .markdown-preview-view h6 { color: #${colors.base0E}; }

            /* Emphasis and strong */
            .cm-em, .markdown-preview-view em { color: #${colors.base0D}; }
            .cm-strong, .markdown-preview-view strong { color: #${colors.base09}; }

            /* Links */
            .cm-link, .markdown-preview-view a { color: #${colors.base0C}; }
            .cm-formatting-link, .cm-url { color: #${colors.base03}; }

            /* Quotes */
            .cm-quote, .markdown-preview-view blockquote { color: #${colors.base0D}; }

            /* Code blocks */
            .HyperMD-codeblock, .markdown-preview-view pre {
              color: #${colors.base07};
              background-color: #${colors.base01};
            }

            .cm-inline-code, .markdown-preview-view code {
              color: #${colors.base07};
              background-color: #${colors.base01};
            }

            /* Cursor */
            .CodeMirror-cursors {
              color: #${colors.base0B};
              z-index: 5;
            }
          '';
        }
      ];
    };
  };
}
