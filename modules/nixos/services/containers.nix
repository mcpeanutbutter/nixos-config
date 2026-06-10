{
  flake.modules.nixos.base = {
    virtualisation = {
      containers.enable = true;
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        # DOCKER-COMPAT (disabled while docker.nix is active — conflicts with
        # virtualisation.docker over the `docker` CLI and /run/docker.sock):
        # dockerCompat = true;
        # dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    # DOCKER-COMPAT (disabled while docker.nix is active — let Docker use its
    # default /run/docker.sock instead of routing to rootless Podman):
    # environment.sessionVariables.DOCKER_HOST = "unix:///run/user/$UID/podman/podman.sock";

    imports = [
      (
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.docker-compose ];
        }
      )
    ];
  };
}
