{ config, ... }:
{
  flake.modules.homeManager.base.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # settings (replaces matchBlocks): attr name = Host/Match header, values = OpenSSH directives.
    settings = {
      "*" = {
        ForwardAgent = true;
        Compression = true;
      };
      "github.com" = {
        IdentityFile = config.user.ssh.personalPrivateKey;
        IdentitiesOnly = true;
      };
    };
  };
}
