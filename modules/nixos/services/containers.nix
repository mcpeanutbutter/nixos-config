{
  flake.modules.nixos.base = {
    virtualisation = {
      containers.enable = true;
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.sessionVariables.DOCKER_HOST = "unix:///run/user/$UID/podman/podman.sock";

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
