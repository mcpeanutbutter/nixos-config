# Real (rootful) Docker daemon. Brought back because Testcontainers needs a true
# Docker socket that rootless Podman's docker-compat shim can't fully emulate
# (Ryuk reaper, /run/docker.sock, privileged/networking).
#
# ─── TO REMOVE DOCKER AND RETURN TO PODMAN-ONLY (docker-compat) ───────────────
#   1. git rm modules/nixos/services/docker.nix
#   2. In modules/nixos/services/containers.nix, re-enable the three lines marked
#      "DOCKER-COMPAT (disabled while docker.nix is active)".
#   3. sudo nixos-rebuild switch --flake .#<hostname>
# ──────────────────────────────────────────────────────────────────────────────
{ config, ... }:
{
  flake.modules.nixos.base = {
    virtualisation.docker.enable = true;
    # Module-system list merge with users.nix's extraGroups setting.
    users.users.${config.user.username}.extraGroups = [ "docker" ];
  };
}
