{
  # PAM service noctalia-shell authenticates against on unlock. Service
  # name matches NOCTALIA_PAM_SERVICE set in the HM noctalia bucket
  # (modules/home/noctalia/niri-glue.nix).
  flake.modules.nixos.noctalia.security.pam.services.noctalia-lock = { };
}
