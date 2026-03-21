{ pkgs, ... }:
{
  imports = [
    ./keymaps.nix
    ./autocommands.nix
    ./lsp.nix
    ./plugins/completion.nix
    ./plugins/formatting.nix
    ./plugins/telescope.nix
    ./plugins/treesitter.nix
    ./plugins/git.nix
    ./plugins/lualine.nix
    ./plugins/ui.nix
    ./plugins/editing.nix
  ];

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text files";
    exec = "${pkgs.ghostty}/bin/ghostty -e nvim %F";
    terminal = false;
    icon = "nvim";
    categories = [
      "Utility"
      "TextEditor"
    ];
  };

  stylix.targets.nixvim = {
    enable = true;
    transparentBackground = {
      main = true;
      numberLine = false;
      signColumn = false;
    };
  };

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    clipboard.register = "unnamedplus";
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraConfigLuaPre = "vim.loader.enable()";

    globals.mapleader = " ";

    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Visual improvements
      cursorline = true;
      termguicolors = true;
      signcolumn = "yes";
      colorcolumn = "100";
      showmode = false;

      # Mouse
      mouse = "a";

      # Indentation
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      breakindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;
      inccommand = "split"; # Live substitution preview

      # Scrolling
      scrolloff = 10;
      sidescrolloff = 8;

      # Splits
      splitbelow = true;
      splitright = true;

      # Folding (treesitter-based)
      foldmethod = "expr";
      foldexpr = "v:lua.vim.treesitter.foldexpr()";
      foldlevelstart = 99;

      # Whitespace visibility
      list = true;
      listchars = "tab:» ,trail:·,nbsp:␣";

      # Misc
      updatetime = 300;
      timeoutlen = 300;
      backup = false;
      writebackup = false;
      swapfile = false;
      undofile = true;
      confirm = true; # Confirm dialog on unsaved changes
    };

    diagnostics = {
      virtual_text = {
        prefix = "●";
      };
      float = {
        border = "rounded";
        style = "minimal";
      };
      severity_sort = true;
      underline = true;
      update_in_insert = false;
      signs = {
        text = {
          "__rawKey__vim.diagnostic.severity.ERROR" = "󰅚";
          "__rawKey__vim.diagnostic.severity.WARN" = "⚠";
          "__rawKey__vim.diagnostic.severity.INFO" = "ⓘ";
          "__rawKey__vim.diagnostic.severity.HINT" = "󰌶";
        };
      };
    };

    # ============================================================
    # COMMENTED OUT PLUGINS (previously used, kept for reference)
    # ============================================================
    # plugins.nvim-tree = {
    #   enable = true;
    #   openOnSetup = false;
    #   autoClose = true;
    # };
    # plugins.nvim-autopairs.enable = true;
    # plugins.comment.enable = true;
    # plugins.indent-blankline.enable = true;
    # plugins.colorizer.enable = true;
    # plugins.rainbow-delimiters.enable = true;
    # plugins.oil.enable = true;
  };
}
