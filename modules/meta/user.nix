{ lib, ... }:
{
  options.user = lib.mkOption {
    type = lib.types.submodule {
      options = {
        username = lib.mkOption { type = lib.types.str; };
        fullName = lib.mkOption { type = lib.types.str; };
        homeDirectory = lib.mkOption { type = lib.types.str; };
        hashedPassword = lib.mkOption { type = lib.types.str; };

        ssh = lib.mkOption {
          type = lib.types.submodule {
            options = {
              personalPrivateKey = lib.mkOption { type = lib.types.str; };
              workPrivateKey = lib.mkOption { type = lib.types.str; };
            };
          };
        };

        git = lib.mkOption {
          type = lib.types.submodule {
            options = {
              name = lib.mkOption { type = lib.types.str; };
              # Per-project git email overrides: <key> -> <directory>.
              # The actual email is decrypted from sops at activation time
              # using the same <key> name as the secret suffix.
              emailOverrides = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = { };
              };
            };
          };
        };
      };
    };
  };

  config.user = {
    username = "jonas";
    fullName = "Jonas Schmoele";
    homeDirectory = "/home/jonas";
    hashedPassword = "$y$j9T$p2llLelVTKXOO3ephZft8/$BsdRjNGLf8e.ypu1q2j72o2rT5e/OPcQmXNMKown/E.";
    ssh = {
      personalPrivateKey = "~/.ssh/id_ed25519_personal";
      workPrivateKey = "~/.ssh/id_ed25519_ingenium";
    };
    git = {
      name = "Jonas Schmoele";
      emailOverrides = {
        personal = "~/projects/personal";
      };
    };
  };
}
