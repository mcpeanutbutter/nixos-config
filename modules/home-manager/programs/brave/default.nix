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

  xdg.desktopEntries.youtube = {
    name = "YouTube";
    exec = "${pkgs.brave}/bin/brave --app=https://www.youtube.com/";
    icon = "youtube";
    categories = [ "AudioVideo" ];
  };

  xdg.desktopEntries.youtube-music = {
    name = "YouTube Music";
    exec = "${pkgs.brave}/bin/brave --app=https://music.youtube.com/";
    icon = "youtube-music";
    categories = [ "AudioVideo" ];
  };

  xdg.desktopEntries.microsoft-teams = {
    name = "Microsoft Teams";
    exec = "${pkgs.brave}/bin/brave --app=https://teams.cloud.microsoft/";
    icon = "com.microsoft.Teams";
    categories = [
      "Network"
      "Chat"
    ];
  };
}
