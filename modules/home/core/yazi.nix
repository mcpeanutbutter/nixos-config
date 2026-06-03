{
  flake.modules.homeManager.base.programs.yazi = {
    enable = true;
    # Pin the `yy` wrapper (HM default became `y` in 26.05).
    shellWrapperName = "yy";
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      preview.wrap = "yes";
    };
  };
}
