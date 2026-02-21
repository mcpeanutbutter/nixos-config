{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.brave;

    # Extensions can be added here if needed
    extensions = [
      # Example: { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
    ];
  };
}
