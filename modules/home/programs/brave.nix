{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, ... }:
      let
        # nixpkgs' Brave wrapper force-enables AcceleratedVideoEncoder (VA-API
        # H264 encode), which is broken in Chromium on this AMD iGPU: Teams /
        # WebRTC screen-share captures fine but encodes 0 frames, so the remote
        # sees a blank share. Disable only the encoder (keep hardware *decode*,
        # AcceleratedVideoDecodeLinuxGL, for playback). The other two disables
        # replicate nixpkgs' own defaults, which our appended --disable-features
        # would otherwise shadow (last --disable-features wins).
        brave = pkgs.brave.override {
          commandLineArgs = "--disable-features=AcceleratedVideoEncoder,OutdatedBuildDetector,UseChromeOSDirectVideoDecoder";
        };
      in
      {
        programs.chromium = {
          enable = true;
          package = brave;
          extensions = [
            # Example: { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
          ];
        };

        xdg.desktopEntries.claude-ai = {
          name = "Claude AI";
          exec = "${brave}/bin/brave --app=https://claude.ai/";
          icon = "claude";
          categories = [ "Utility" ];
        };

        xdg.desktopEntries.youtube = {
          name = "YouTube";
          exec = "${brave}/bin/brave --app=https://www.youtube.com/";
          icon = "youtube";
          categories = [ "AudioVideo" ];
        };

        xdg.desktopEntries.youtube-music = {
          name = "YouTube Music";
          exec = "${brave}/bin/brave --app=https://music.youtube.com/";
          icon = "youtube-music";
          categories = [ "AudioVideo" ];
        };

        xdg.desktopEntries.microsoft-teams = {
          name = "Microsoft Teams";
          exec = "${brave}/bin/brave --app=https://teams.cloud.microsoft/";
          icon = "com.microsoft.Teams";
          categories = [
            "Network"
            "Chat"
          ];
        };
      }
    )
  ];
}
