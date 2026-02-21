{ ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    clipboard.register = "unnamedplus";
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    globals.mapleader = " ";

    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Visual improvements
      cursorline = true;
      termguicolors = true;
      signcolumn = "yes";

      # Indentation
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # Scrolling
      scrolloff = 8;
      sidescrolloff = 8;

      # Splits
      splitbelow = true;
      splitright = true;

      # Folding
      foldlevelstart = 99;

      # Misc
      updatetime = 300;
      timeoutlen = 500;
      backup = false;
      writebackup = false;
      swapfile = false;
      undofile = true;
    };

    keymaps = [
      # Better window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }

      # Resize with arrows
      {
        mode = "n";
        key = "<C-Up>";
        action = ":resize +2<CR>";
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = ":resize -2<CR>";
      }
      {
        mode = "n";
        key = "<C-Left>";
        action = ":vertical resize -2<CR>";
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = ":vertical resize +2<CR>";
      }

      # Better indenting
      {
        mode = "v";
        key = "<";
        action = "<gv";
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
      }

      # Move text up and down
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
      }

      # Clear search highlight
      {
        mode = "n";
        key = "<leader>h";
        action = ":nohlsearch<CR>";
      }

      # File operations
      {
        mode = "n";
        key = "<leader>w";
        action = ":w<CR>";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = ":q<CR>";
      }
      {
        mode = "n";
        key = "<leader>x";
        action = ":x<CR>";
      }

      # Telescope
      {
        mode = "n";
        key = "<leader>ff";
        action = ":Telescope find_files<CR>";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = ":Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = ":Telescope buffers<CR>";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = ":Telescope help_tags<CR>";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = ":Telescope oldfiles<CR>";
      }

      # Oil file manager
      {
        mode = "n";
        key = "<leader>o";
        action = ":Oil<CR>";
      }

      # Tree toggle
      {
        mode = "n";
        key = "<leader>e";
        action = ":NvimTreeToggle<CR>";
      }
    ];

    plugins = {
      # File explorer
      nvim-tree = {
        enable = true;
        openOnSetup = false;
        autoClose = true;
      };

      # Status line
      lualine = {
        enable = true;
        settings.options.globalstatus = true;
      };

      # Buffer line
      bufferline.enable = true;

      # Fuzzy finder
      telescope.enable = true;

      # Syntax highlighting
      treesitter = {
        enable = true;
        nixvimInjections = true;
        folding.enable = true;
        settings.indent.enable = true;
        languageRegister = {
          hcl = [
            "tf"
            "terraform"
            "tofu"
          ];
        };
      };

      # Auto completion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
            { name = "luasnip"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-e>" = "cmp.mapping.close()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
          snippet = {
            expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
          };
        };
      };

      # Snippets
      luasnip.enable = true;

      # Auto pairs
      nvim-autopairs.enable = true;

      # Commenting
      comment.enable = true;

      # Git integration
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };

      # Indentation guides
      indent-blankline.enable = true;

      # Color highlighter
      colorizer.enable = true;

      # Surround text objects
      nvim-surround.enable = true;

      # Which-key for keybinding help
      which-key.enable = true;

      # Icons
      web-devicons.enable = true;

      # Rainbow delimiters
      rainbow-delimiters.enable = true;

      # Oil file manager
      oil.enable = true;

      # LSP formatting
      lsp-format.enable = true;

      # Formatter
      none-ls = {
        enable = true;
        sources.formatting.opentofu_fmt = {
          enable = true;
          settings = {
            extra_filetypes = [
              "tofu"
            ];
          };
        };
      };
    };

    plugins.lsp = {
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
  };
}
