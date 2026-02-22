# NixOS Configuration

A modular NixOS configuration managed through Nix Flakes. Currently configured for two machines — `amateria` (Framework 16 laptop) and `selenitic`. The repository uses a clean separation between host-specific, user-specific, and reusable module layers.

## Directory Structure

```
├── flake.nix                    # Flake definition: inputs, host configs, mkNixosConfiguration
├── flake.lock                   # Locked input versions
├── users/<username>/            # User identity (name, password, ssh/git settings)
├── hosts/<hostname>/            # NixOS config per host (imports + hardware)
│   ├── default.nix
│   └── hardware-configuration.nix
├── home/<username>/<hostname>/  # Home Manager config per user+host
│   └── default.nix
├── modules/
│   ├── nixos/                   # Reusable NixOS modules (system-level)
│   │   ├── common/              # Bootloader, kernel, networking, audio, users, locale
│   │   ├── desktop/             # Desktop environment (niri/)
│   │   ├── programs/            # System programs (docker/)
│   │   └── services/            # System services (stylix/, sops/, bitdefender/, clamav/)
│   └── home-manager/            # Reusable Home Manager modules (user-level)
│       ├── common/              # Shared packages, programs, session config
│       ├── desktop/             # Desktop user config (niri/, waybar/, mako/, swww/)
│       └── programs/            # Per-program config (git/, zsh/, nixvim/, sops/, etc.)
├── overlays/                    # Package overlays (stable packages, custom versions)
└── secrets/                     # Sops-encrypted secrets (git emails, SSH config)
```

## Adding a New Host

This guide walks through adding a new machine to this configuration. Most of the work happens on an **existing machine** where the repo already lives — only hardware discovery and key placement require the new machine.

> **Why sops matters**: `modules/home-manager/common` unconditionally imports `programs/sops`, which the `git` module (email identities) and `ssh` module (work config) depend on. This means every host needs the **user age key** at `~/.config/sops/age/keys.txt` — without it, the build fails. Separately, some hosts may also use **NixOS-level sops** (via `services/sops`) for system-level secrets like antivirus tokens — this uses the host's SSH key and is only needed if you import that module.

### Phase 1: Create the host configuration `[existing machine]`

All config files can be written on any machine where the repo already lives.

1. **Add the host entry to `flake.nix`** in the `hosts` object:

   ```nix
   hosts = {
     # ... existing hosts ...
     <hostname> = {
       system = "x86_64-linux";
       theme = "material-darker";
       stateVersion = "25.11";          # Match the NixOS release you'll install
       desktopEnvironment = "niri";
       thermalZone = null;              # Optional — can be set after first boot
      hwmon = null;                    # Optional — alternative to thermalZone for AMD systems
     };
   };
   ```

2. **Register in `nixosConfigurations`** (also in `flake.nix`):

   ```nix
   nixosConfigurations = {
     # ... existing hosts ...
     <hostname> = mkNixosConfiguration "<hostname>" "jonas";
   };
   ```

3. **Create `hosts/<hostname>/default.nix`** — copy from an existing host like `amateria` and adjust. Leave `hardware-configuration.nix` absent for now (generated in Phase 2):

   ```nix
   {
     hostname,
     nixosModules,
     hostConfig,
     ...
   }:
   {
     imports = [
       ./hardware-configuration.nix
       "${nixosModules}/common"
       "${nixosModules}/desktop/${hostConfig.desktopEnvironment}"
       "${nixosModules}/programs/docker"
       "${nixosModules}/services/stylix"
       # "${nixosModules}/services/sops"        # Only if using NixOS-level secrets (see Phase 3)
       # "${nixosModules}/services/bitdefender"  # Optional, requires services/sops
       # "${nixosModules}/services/clamav"       # Optional
     ];

     networking.hostName = hostname;

     system.stateVersion = hostConfig.stateVersion;
   }
   ```

4. **Create `home/jonas/<hostname>/default.nix`** — copy from an existing host. Monitor config is a placeholder until first boot:

   ```nix
   {
     lib,
     nhModules,
     hostConfig,
     ...
   }:
   {
     imports =
       [
         "${nhModules}/common"
       ]
       ++ lib.optionals (hostConfig.desktopEnvironment == "niri") [
         "${nhModules}/desktop/niri"
         "${nhModules}/desktop/waybar"
         "${nhModules}/desktop/mako"
         "${nhModules}/desktop/swww"
       ];

     # Monitor configuration — update after first boot with actual output names
     programs.niri.settings.outputs = { };

     programs.home-manager.enable = true;

     home.stateVersion = hostConfig.stateVersion;
   }
   ```

5. **Commit and push** so the configuration is available to clone on the new machine.

### Phase 2: Prepare the new machine `[new machine]`

These steps require the new hardware.

1. **Install NixOS** using the standard installer (minimal or graphical). Boot into the fresh install.

2. **Clone the repo**:

   ```bash
   git clone https://github.com/mcpeanutbutter/nixos-config.git ~/nixos-config
   ```

3. **Generate `hardware-configuration.nix`** directly into the repo:

   ```bash
   nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/<hostname>/hardware-configuration.nix
   ```

4. **Place the user age key** — copy from your password manager or another machine:

   ```bash
   mkdir -p ~/.config/sops/age
   # Paste or copy your key into ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```

   The key's public half must match the `&jonas` anchor in `.sops.yaml`. No changes to `.sops.yaml` are needed — the user key is already listed.

   If you don't have a user age key yet (first-time setup):
   ```bash
   nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"
   ```
   Then add the public key to `.sops.yaml` and run `sops updatekeys` on all secret files.

### Phase 3: NixOS-level sops setup `[both machines, optional]`

**Skip this phase entirely** if the host's `default.nix` does not import `"${nixosModules}/services/sops"`. You only need this for hosts that run services requiring system-level secrets (e.g., BitDefender reads tokens from `secrets.yaml` at boot).

NixOS-level sops uses the **host's SSH ed25519 key** converted to age. There's a chicken-and-egg problem: sops-nix needs the host key to decrypt secrets at boot, but the key doesn't exist until openssh first starts. Solution: pre-generate the key.

1. **Generate the SSH host key** on the new machine:

   ```bash
   sudo mkdir -p /etc/ssh
   sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   ```

2. **Derive the age public key** from the new host's SSH key:

   ```bash
   nix-shell -p ssh-to-age --run 'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
   ```

3. **Add the host key to `.sops.yaml`** (on the existing machine or any machine with the repo):

   ```yaml
   keys:
     - &selenitic age15kvpw8grrnjn3e609rju5e0p5f3fs4gradxr36dh9mksl25g3vssz54v43
     - &<hostname> age1...   # public key from step 2
     - &jonas age1dlcau98tlksg4xcg32rae7cyrhdxky8gtlagjhma5xprwfqqks2q7hs6k6
   creation_rules:
     - path_regex: secrets/.*\.yaml$
       key_groups:
         - age:
             - *selenitic
             - *<hostname>
             - *jonas
   ```

4. **Re-encrypt all secret files** so the new host key can decrypt them:

   ```bash
   sops updatekeys secrets/secrets.yaml
   sops updatekeys secrets/ssh.yaml
   ```

5. Commit and push the updated `.sops.yaml` and re-encrypted secrets.

### Phase 4: Deploy `[new machine]`

1. **Pull the latest changes** (the repo was cloned in Phase 2):

   ```bash
   cd ~/nixos-config
   git pull
   ```

2. **Stage all files** — flake requires tracked files:

   ```bash
   git add .
   ```

3. **Build and switch** (a fresh NixOS install doesn't have flakes enabled, so pass the flag inline — the config enables them permanently after this):

   ```bash
   sudo NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#<hostname>
   ```

4. **After first boot** — tune hardware-specific settings and rebuild:

   - **Monitor config**: check output names with `niri msg outputs` or `wlr-randr`, then update `programs.niri.settings.outputs` in `home/jonas/<hostname>/default.nix`.

   - **CPU temperature** (for waybar): there are two options depending on hardware. Set the relevant field in the host's config in `flake.nix`.

     **Option A — `thermalZone`** (Intel laptops and other systems with ACPI thermal zones):

     ```bash
     for zone in /sys/class/thermal/thermal_zone*; do
       echo "$(basename $zone): $(cat $zone/type)"
     done
     ```

     Look for `x86_pkg_temp` or similar. Use the zone number (e.g., `5` for `thermal_zone5`).

     **Option B — `hwmon`** (AMD desktops and other systems without thermal zones):

     ```bash
     for dir in /sys/class/hwmon/hwmon*; do
       echo "$(basename $dir): $(cat $dir/name)"
     done
     ```

     Look for `k10temp` (AMD) or similar. Then set `hwmon` in `flake.nix`:

     ```nix
     hwmon = {
       path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";  # readlink -f /sys/class/hwmon/hwmonN
       input = "temp1_input";  # Tctl (CPU control temp)
     };
     ```

     If neither applies, leave both as `null` to disable the temperature display.

5. **Commit and push** — the repo was cloned over HTTPS (read-only). To push, switch the remote to SSH and ensure the machine has an SSH key registered with your Git host:

   ```bash
   git remote set-url origin git@github.com:mcpeanutbutter/nixos-config.git
   git add .
   git commit -m "Add <hostname> host configuration"
   git push
   ```

### Troubleshooting

**"error: getting status of '/nix/store/.../<filename>': No such file or directory"**
You forgot `git add .` — flake can't see untracked files.

**Sops decryption failure at activation**
- Home-manager sops: check that `~/.config/sops/age/keys.txt` exists and its public key matches the `&jonas` entry in `.sops.yaml`.
- NixOS-level sops: check that `/etc/ssh/ssh_host_ed25519_key` exists and its derived age key is in `.sops.yaml`. Ensure you ran `sops updatekeys` on all secret files.

**"attribute '<hostname>' missing"**
The hostname isn't in the `hosts` object or `nixosConfigurations` in `flake.nix`.

**Hardware issues after first boot**
Regenerate hardware config: `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`, rebuild, and check for missing firmware packages.

**Host reinstalled, sops broken**
A reinstall generates a new SSH host key. Re-derive the age key with `ssh-to-age`, update `.sops.yaml`, and run `sops updatekeys` on all secret files.

## Secrets Management

### Two-key model

This configuration uses [sops-nix](https://github.com/Mic92/sops-nix) with two types of age keys:

| Type | Derived from | Used by | Purpose |
|------|-------------|---------|---------|
| **User key** | Standalone age key | Home Manager sops (`modules/home-manager/programs/sops/`) | Decrypts user-level secrets (git emails, SSH config). Required on all hosts. |
| **Host key** | Host's SSH ed25519 key | NixOS-level sops (`modules/nixos/services/sops/`) | Decrypts system-level secrets at boot. Only needed if importing the sops NixOS service. |

### Key reference

| Key | Path | Purpose |
|-----|------|---------|
| User private key | `~/.config/sops/age/keys.txt` | Decrypts user-level secrets; also used to edit secrets via `sops` CLI |
| Host private key | `/etc/ssh/ssh_host_ed25519_key` | Converted to age at boot to decrypt NixOS-level secrets |
| Public keys | Listed in `.sops.yaml` | Determine which keys can decrypt the secret files |

### Current keys

| Name | Type | Age public key |
|------|------|---------------|
| `selenitic` | Host | `age15kvpw8grrnjn3e609rju5e0p5f3fs4gradxr36dh9mksl25g3vssz54v43` |
| `jonas` | User | `age1dlcau98tlksg4xcg32rae7cyrhdxky8gtlagjhma5xprwfqqks2q7hs6k6` |

### Editing secrets

```bash
# Edit secrets (requires user age key at ~/.config/sops/age/keys.txt):
sops secrets/secrets.yaml
sops secrets/ssh.yaml

# After adding a new key to .sops.yaml, re-encrypt for all keys:
sops updatekeys secrets/secrets.yaml
sops updatekeys secrets/ssh.yaml
```

Encrypted secret files (`secrets/*.yaml`) are safe to commit — only keys listed in `.sops.yaml` can decrypt them.

## Build Commands

```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Test configuration without making it the boot default
sudo nixos-rebuild test --flake .#<hostname>

# Build without activating
sudo nixos-rebuild build --flake .#<hostname>

# Update all flake inputs
nix flake update

# Update a specific input
nix flake update nixpkgs

# Check flake for errors
nix flake check
```

Home Manager is integrated as a NixOS module — it rebuilds automatically with `nixos-rebuild switch`. There's no separate `home-manager` command.

## Common Tasks

### Adding a user-level application

1. Create `modules/home-manager/programs/<appname>/default.nix`
2. Import it in `modules/home-manager/common/default.nix`

### Adding a system-level service

1. Create `modules/nixos/services/<servicename>/default.nix`
2. Import it in the relevant host's `hosts/<hostname>/default.nix`

### Adding a desktop-specific module

1. Create it in `modules/home-manager/desktop/<name>/` or `modules/nixos/desktop/<name>/`
2. Add conditional imports in `home/<username>/<hostname>/default.nix` or `hosts/<hostname>/default.nix`

## Architecture Notes

### mkNixosConfiguration

The `mkNixosConfiguration` function in `flake.nix` wires everything together for a given hostname and username. It automatically:
- Loads `hosts/<hostname>/` (NixOS config)
- Loads `home/<username>/<hostname>/` (Home Manager config)
- Passes `userConfig`, `hostConfig`, and module path variables to all modules

### Special arguments

NixOS modules receive: `inputs`, `outputs`, `hostname`, `userConfig`, `hostConfig`, `nixosModules`

Home Manager modules receive: `inputs`, `outputs`, `vscode-extensions`, `userConfig`, `hostConfig`, `nhModules`

### Overlays

Defined in `overlays/default.nix` and applied via `modules/nixos/common/`. Used for stable package imports (`pkgs.stable.*`) and custom package version overrides.

### stateVersion

Set in the host config object in `flake.nix` and referenced by both `system.stateVersion` and `home.stateVersion`. Should match the NixOS release the host was **first installed** with — do not bump it on upgrades.

## TODO

- **kanshi for automatic display switching**: Add a kanshi home-manager module (`modules/home-manager/desktop/kanshi/`) that auto-disables eDP-1 when an external monitor (e.g. DP-3) is connected, and re-enables it when undocked. kanshi uses wlr-output-management which niri supports. Could reuse `hostConfig.monitors` data to define per-host docking profiles.
