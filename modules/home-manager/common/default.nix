{
  outputs,
  userConfig,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/brave
    ../programs/direnv
    ../programs/sops
    ../programs/eza
    ../programs/fuzzel
    ../programs/fzf
    ../programs/ghostty
    ../programs/git
    ../programs/gtk
    ../programs/kitty
    ../programs/nixvim
    ../programs/ssh
    ../programs/vscode
    ../programs/yazi
    # ../programs/zed
    ../programs/zsh
  ];

  # Nixpkgs configuration is managed at the system level when using home-manager as a NixOS module
  # with useGlobalPkgs = true

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Home-Manager configuration for the user's home environment
  home = {
    username = userConfig.username;
    homeDirectory = userConfig.homeDirectory;
  };

  # Session variables
  home.sessionVariables = {
    LC_ALL = "en_US.UTF-8";
  };

  # File symlinks
  home.file.".lib/zsh".source = pkgs.zsh;

  # Common packages
  home.packages =
    with pkgs;
    let
      gdk = pkgs.google-cloud-sdk.withExtraComponents (
        with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
      );
    in
    [
      ansible
      ansible-lint
      pkgs.unstable.claude-code
      clusterctl
      dbeaver-bin
      devenv
      drawio
      # element-desktop
      fastfetch
      gdk
      gemini-cli
      gimp
      handbrake
      htop
      inkscape
      jdk
      jetbrains.idea-oss
      kind
      kubectl
      libreoffice
      libnotify
      lm_sensors
      mongodb-compass
      mprime
      mpv
      pkgs.unstable.nixd
      nixfmt
      obsidian
      openfortivpn
      opentofu
      pdfarranger
      poetry
      postman
      qalculate-qt
      ripgrep
      s-tui
      signal-desktop
      slack
      stress-ng
      sysbench
      telegram-desktop
      thunderbird
    ];

  # Enable common programs
  programs = {
    bat.enable = true;
    btop.enable = true;
    git.enable = true;
    home-manager.enable = true; # Let Home Manager install and manage itself
  };
}
