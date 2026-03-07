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

  xdg.desktopEntries.claude-ai = {
    name = "Claude AI";
    exec = "${pkgs.brave}/bin/brave --app=https://claude.ai/";
    icon = "claude";
    categories = [ "Utility" ];
  };
}
