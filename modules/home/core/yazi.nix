{ lib, ... }:
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
    # Restore yazi's upstream reverse-video hovered row. Stylix's yazi
    # target sets a fixed base02 bg bar; mkForce replaces it wholesale so
    # `reversed` doesn't merge with (and swap in) that bg.
    theme.indicator = {
      current = lib.mkForce { reversed = true; };
      preview = lib.mkForce { reversed = true; };
    };
  };
}
