# Dendritic refactor — activation checklist

The dendritic refactor (`refactor/dendritic` branch) is complete from a code
standpoint. Three NixOS hosts still need to be activated on the new config.
This file is the single source of truth for what's left to do.

If a fresh Claude Code session asks **what's left to ship this refactor?**,
the answer is the unticked boxes below. Tick them as you go; future-you
(or future Claude) will see exactly where the live work stands.

## Status of each host

`refactor/dendritic` is local-only on `spire` at the moment. To run it on
`amateria` and `selenitic`, push the branch first:

- [ ] `git push -u origin refactor/dendritic` (run once, from any host)

Verification status — these confirm the flake compiles and the per-host
toplevel evaluates to a valid drvPath. Already passing locally:

- [x] `nix eval --raw .#nixosConfigurations.amateria.config.system.build.toplevel.drvPath`
- [x] `nix eval --raw .#nixosConfigurations.selenitic.config.system.build.toplevel.drvPath`
- [x] `nix eval --raw .#nixosConfigurations.spire.config.system.build.toplevel.drvPath`

## Per-host activation

### spire (AMD desktop — current host as of refactor)

- [x] `cd ~/nixos-config && git switch refactor/dendritic`
- [x] `nix flake check` — expect no errors (empty `flake.modules` warnings are OK)
- [ ] `sudo nixos-rebuild test --flake .#spire` — activates new config without setting it as default boot
- [ ] Spot-checks (see "Functional spot-checks" below). Mark each pass.
- [ ] `sudo nixos-rebuild switch --flake .#spire` — sets new config as default

### selenitic (ThinkPad T480s — personal)

- [ ] `cd ~/nixos-config && git fetch && git switch refactor/dendritic`
- [ ] `nix flake check`
- [ ] `sudo nixos-rebuild test --flake .#selenitic`
- [ ] Spot-checks
- [ ] `sudo nixos-rebuild switch --flake .#selenitic`

### amateria (Framework 16 — work machine)

- [ ] `cd ~/nixos-config && git fetch && git switch refactor/dendritic`
- [ ] `nix flake check`
- [ ] `sudo nixos-rebuild test --flake .#amateria`
- [ ] Spot-checks (including the **work-only** ones)
- [ ] `sudo nixos-rebuild switch --flake .#amateria`

## Functional spot-checks

Run these after each host's `test`-activation. They cover the things most
likely to silently break across a layout refactor.

### All hosts

- [ ] **Niri launches** and keybindings work (`Mod+T` for ghostty,
      `Mod+D` for fuzzel, `Mod+B` for brave, `Mod+Alt+X` for power menu)
- [ ] **Waybar renders** the temperature widget — read the actual temperature,
      not "n/a"
- [ ] **Notifications** fire: `notify-send hello`
- [ ] **Starship prompt** renders in a fresh shell
- [ ] **Git personal email** correct inside `~/projects/personal/`:
      `cd ~/projects/personal/<any> && git config --get user.email`
- [ ] **nvim launches** and loads plugins (run `:checkhealth` to see LSP servers attached)
- [ ] **VSCode** opens, marketplace extensions resolve (`code --list-extensions`)
- [ ] **sops** decrypts: easiest functional check is the git-email one above
      (the personal email lives in sops; if `git config --get user.email`
      returns the right address, sops + home-manager activation worked).
      `journalctl -u sops-install-secrets --no-pager | tail` is **only meaningful
      on amateria** — the work bucket declares NixOS-level sops secrets
      (`bitdefender/*`, `vpn/*`, `glpi/*`). On selenitic / spire there are no
      NixOS-level secrets to install, so "No entries" is expected and healthy;
      the personal git email is an HM-level secret handled separately.
- [ ] **Docker rootless** works: `docker run --rm hello-world` (as your user)
- [ ] **Stylix theming** applied to GTK apps (file manager etc.) — compare a window
      to expected Material-Darker look
- [ ] **Niri output** matches the host's `displays.nix`: external monitor at
      the configured resolution + scale, laptop panel as expected

### amateria only (work-bucket checks)

- [ ] **Work git email** correct inside `~/projects/work/`:
      `cd ~/projects/work/<any> && git config --get user.email`
- [ ] **Work SSH key**: `ssh -G gitlab.bbf-it.at | grep -i identityfile` → points
      at `~/.ssh/id_ed25519_ingenium`
- [ ] **BitDefender container** present: `systemctl status podman-BSC.service`
- [ ] **GLPI agent** present: `systemctl status glpi-agent.service`
- [ ] **VPN profile** present in NetworkManager: `nmcli connection show | grep "Work VPN"`
- [ ] **BSC waybar widget** visible in the right segment of waybar (the
      shield icon — visual confirmation)

### selenitic / spire only (no work bucket)

- [ ] BitDefender, GLPI, Work VPN, BSC widget all absent.

## If something breaks during `test`

`test` doesn't change the default boot, so just `sudo nixos-rebuild switch
--rollback` (or reboot) to go back to the pre-refactor generation.

For configuration-eval errors (vs. activation-time errors): look at
`/etc/nixos/configuration.nix` paths in the error trace — anything pointing
into the old `hosts/`, `home/`, `users/` directories means the refactor's
purge missed something. The new tree is entirely under `./modules/`.

## Merging back

When all three hosts are happily on `switch`-activated dendritic configs:

- [ ] `git switch main && git merge --ff-only refactor/dendritic && git push`
- [ ] Delete the activation checklist or move it into project memory once
      everything's stable (it's served its purpose at that point).
