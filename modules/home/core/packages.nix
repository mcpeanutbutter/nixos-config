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
            gdk
            pkgs.unstable.godot
            gimp
            glab
            handbrake
            htop
            inkscape
            jdk
            pkgs.unstable.jetbrains.idea
            kind
            kubectl
            libreoffice
            libnotify
            lm_sensors
            mongodb-compass
            mprime
            mpv
            onefetch
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
            uv
          ];
      }
    )
  ];
}
