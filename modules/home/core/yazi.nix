{
  flake.modules.homeManager.base.programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      preview.wrap = "yes";
    };
  };
}
