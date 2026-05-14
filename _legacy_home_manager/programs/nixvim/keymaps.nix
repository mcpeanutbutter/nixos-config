{ ... }:
{
  programs.nixvim.keymaps = [
    # -- Window navigation (from kickstart.nvim) --
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Move to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Move to bottom window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Move to top window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Move to right window";
    }

    # -- Terminal --
    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }

    # -- Search --
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Clear search highlights";
    }

    # -- Diagnostics (from kickstart.nvim) --
    {
      mode = "n";
      key = "<leader>q";
      action = ":lua vim.diagnostic.setloclist()<CR>";
      options.desc = "Diagnostic quickfix list";
    }
  ];
}
