{ config, ... }:
{
  sops.secrets."bitdefender/company" = { };
  sops.secrets."bitdefender/csrtoken" = { };

  sops.templates."bitdefender-env".content = ''
    BSC_COMPANY=${config.sops.placeholder."bitdefender/company"}
    BSC_CSRTOKEN=${config.sops.placeholder."bitdefender/csrtoken"}
  '';

  systemd.tmpfiles.rules = [ "d /mnt/data 0755 root root -" ];

  virtualisation.oci-containers.containers.bitdefender = {
    image = "bdfbusiness/bitdefender-security-container:7.0";
    user = ":10000";
    environment.BSC_SERVER = "https://cloudgz-ecs.gravityzone.bitdefender.com";
    environmentFiles = [ config.sops.templates."bitdefender-env".path ];
    volumes = [
      "/mnt/data:/data"
      "/sys:/mnt/host-sys"
      "/proc:/mnt/host-proc"
      "/etc/os-release:/mnt/host-os-release"
      "/:/mnt/host"
    ];
    extraOptions = [
      "--privileged"
      "--pid=host"
      "--net=host"
      "--stop-timeout=60"
    ];
  };
}
