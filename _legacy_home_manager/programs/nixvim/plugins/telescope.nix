{ ... }:
{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      extensions = {
        fzy-native.enable = true;
        ui-select.enable = true;
      };
      settings = {
        defaults = {
          layout_strategy = "vertical";
          layout_config = {
            vertical = {
              width = 0.99;
              height = 0.99;
              prompt_position = "bottom";
              preview_cutoff = 0;
            };
          };
          vimgrep_arguments = [
            "rg"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
          ];
          mappings = {
            i = {
              "<C-q>".__raw = "require('telescope.actions').send_to_qflist";
              "<C-l>".__raw = "require('telescope.actions').send_to_loclist";
            };
            n = {
              "q".__raw = "require('telescope.actions').close";
            };
          };
        };
      };
    };

    # Telescope keymaps (kickstart.nvim style)
    extraConfigLua = ''
      local builtin = require('telescope.builtin')

      -- Keymaps from kickstart.nvim (search prefix)
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search help' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search keymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search files' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Search telescope pickers' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Search current word' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search by grep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search diagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search resume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search recent files' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = 'Search commands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Find buffers' })

      -- Fuzzy find in current buffer
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = 'Fuzzy find in current buffer' })

      -- Search in open files
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
      end, { desc = 'Search in open files' })
    '';
  };
}
