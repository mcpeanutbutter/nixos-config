{
  flake.modules.homeManager.base.imports = [
    (
      { pkgs, ... }:
      {
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
            clusterctl
            dbeaver-bin
            devenv
            drawio
            # element-desktop
            fastfetch
            gdk
            gemini-cli
            gimp
            glab
            handbrake
            htop
            inkscape
            jdk
            pkgs.unstable.jetbrains.idea-oss
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

            opentofu
            pdfarranger
            poetry
            postman
            qalculate-qt
            ripgrep
            s-tui
            slack
            stress-ng
            sysbench
            thunderbird
          ];
      }
    )
  ];
}
