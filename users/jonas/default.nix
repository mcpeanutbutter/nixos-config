{
  username = "jonas";
  fullName = "Jonas Schmoele";
  homeDirectory = "/home/jonas";
  hashedPassword = "$y$j9T$p2llLelVTKXOO3ephZft8/$BsdRjNGLf8e.ypu1q2j72o2rT5e/OPcQmXNMKown/E.";
  ssh = {
    personalPrivateKey = "~/.ssh/id_ed25519_personal";
  };
  git = {
    name = "Jonas Schmoele";
    # Directory -> sops key suffix mapping for per-project email overrides
    emailOverrides = {
      personal = "~/projects/personal";
      work = "~/projects/work";
    };
  };
}
