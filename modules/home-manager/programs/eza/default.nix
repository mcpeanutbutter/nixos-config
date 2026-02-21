{ ... }:
{
  programs.eza = {
    enable = true;
    icons = "auto";
    extraOptions = [
      "--color=always"
      "--group-directories-first"
      "--header"
      "--long"
      "--time-style=long-iso"
    ];
  };
}
