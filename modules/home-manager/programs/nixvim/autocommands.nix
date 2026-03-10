{ ... }:
{
  programs.nixvim = {
    autoCmd = [
      # Highlight on yank
      {
        event = "TextYankPost";
        desc = "Highlight when yanking text";
        callback.__raw = ''
          function()
            vim.highlight.on_yank()
          end
        '';
      }

      # Disable undofile in /tmp
      {
        event = "BufWritePre";
        pattern = "/tmp/*";
        desc = "Disable undofile for /tmp";
        callback.__raw = ''
          function()
            vim.opt_local.undofile = false
          end
        '';
      }

      # Disable spell in terminal
      {
        event = "TermOpen";
        desc = "Disable spell in terminal";
        callback.__raw = ''
          function()
            vim.opt_local.spell = false
          end
        '';
      }

      # Disable auto-comment on new lines
      {
        event = "FileType";
        desc = "Disable auto-comment on new lines";
        callback.__raw = ''
          function()
            vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
          end
        '';
      }

      # Enable spell check for prose filetypes only
      {
        event = "FileType";
        pattern = [
          "markdown"
          "text"
          "gitcommit"
          "plaintex"
          "tex"
        ];
        desc = "Enable spell check for prose filetypes";
        callback.__raw = ''
          function()
            vim.opt_local.spell = true
            vim.opt_local.spelllang = 'en'
          end
        '';
      }

      # LSP attach keymaps (kickstart.nvim gr* style)
      {
        event = "LspAttach";
        desc = "LSP keymaps and settings";
        callback.__raw = ''
          function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            local bufnr = event.buf
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
            end

            -- kickstart.nvim style gr* keymaps
            local builtin = require('telescope.builtin')
            map('grn', vim.lsp.buf.rename, 'Rename')
            map('gra', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
            map('grD', vim.lsp.buf.declaration, 'Goto declaration')
            map('grr', builtin.lsp_references, 'Goto references')
            map('gri', builtin.lsp_implementations, 'Goto implementation')
            map('grd', builtin.lsp_definitions, 'Goto definition')
            map('grt', builtin.lsp_type_definitions, 'Goto type definition')
            map('gO', builtin.lsp_document_symbols, 'Document symbols')
            map('gW', builtin.lsp_dynamic_workspace_symbols, 'Workspace symbols')

            -- Format via conform
            map('<leader>f', function()
              require('conform').format({ async = true, lsp_format = 'fallback' })
            end, 'Format buffer')

            -- Toggle inlay hints
            if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
              map('<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
              end, 'Toggle inlay hints')
            end

            -- Attach navic for breadcrumbs
            if client and client.server_capabilities.documentSymbolProvider then
              require('nvim-navic').attach(client, bufnr)
            end

            -- Document highlight on hover (from kickstart.nvim)
            if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
              local highlight_group = vim.api.nvim_create_augroup('lsp-highlight-' .. bufnr, { clear = true })
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = bufnr,
                group = highlight_group,
                callback = vim.lsp.buf.document_highlight,
              })
              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = bufnr,
                group = highlight_group,
                callback = vim.lsp.buf.clear_references,
              })
              vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp-detach-' .. bufnr, { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds({ group = 'lsp-highlight-' .. event2.buf })
                end,
              })
            end

          end
        '';
      }
    ];
  };
}
