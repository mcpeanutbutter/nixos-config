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
│   │   ├── desktop/             # Desktop environments (kde/, niri/)
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

This is the step-by-step process for adding a new machine to this configuration.

### Phase 1: Install NixOS on the target machine

1. Install NixOS on the target machine using the standard installer (graphical or minimal ISO).
2. Boot into the fresh install and verify you can log in.
3. Clone this repository onto the new machine:
   ```bash
   git clone <repo-url> ~/nixos-config
   cd ~/nixos-config
   ```

### Phase 2: Gather hardware info

1. **Generate the hardware configuration** — this captures your disk layout, kernel modules, firmware, etc.:
   ```bash
   nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```
   Create the directory first: `mkdir -p hosts/<hostname>`

2. **Determine the thermal zone** (used by waybar for CPU temperature display):
   ```bash
   # List all thermal zones and their types:
   for zone in /sys/class/thermal/thermal_zone*; do
     echo "$(basename $zone): $(cat $zone/type)"
   done
   ```
   Look for `x86_pkg_temp`, `k10temp`, or similar CPU package temperature zone. Note the zone number (e.g., `5` for `thermal_zone5`). If you don't need CPU temp in waybar or the machine is headless, use `null`.

### Phase 3: Set up sops on the new machine

Every host needs sops at the home-manager level — it's unconditionally imported by `modules/home-manager/common/` and used by the `git` and `ssh` modules. Home-manager sops uses a **user age key**, not the host's SSH key.

#### Required for all hosts: user age key

Copy your existing age private key to the new machine:
```bash
mkdir -p ~/.config/sops/age
# Copy from another machine or password manager:
cp /path/to/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

The user key (`jonas`) is already in `.sops.yaml`, so no changes to `.sops.yaml` are needed for home-manager sops. The key file just needs to exist at `~/.config/sops/age/keys.txt` on the new machine.

If you don't have a user age key yet:
```bash
mkdir -p ~/.config/sops/age
nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"
```
Then add the public key to `.sops.yaml` and run `sops updatekeys` on all secret files (see below).

#### Conditional: NixOS-level sops (only if importing `services/sops`)

This is only needed if your host's `default.nix` imports `"${nixosModules}/services/sops"` (e.g., for system-level secrets like antivirus tokens). If you skip this import, you can skip this entire section.

NixOS-level sops uses the **host's SSH ed25519 key** converted to age. There's a chicken-and-egg problem: sops-nix needs the host key to decrypt secrets at boot, but the key doesn't exist until openssh first activates. Solution: manually pre-generate the key.

1. **Generate the SSH host key** on the new machine:
   ```bash
   sudo mkdir -p /etc/ssh
   sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   ```

2. **Derive the host's age public key**:
   ```bash
   nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
   ```

3. **Add the host key to `.sops.yaml`** — on any machine with the user age key:
   ```yaml
   keys:
     - &selenitic age15kvpw8grrnjn3e609rju5e0p5f3fs4gradxr36dh9mksl25g3vssz54v43
     - &newhostname age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     - &jonas age1dlcau98tlksg4xcg32rae7cyrhdxky8gtlagjhma5xprwfqqks2q7hs6k6
   creation_rules:
     - path_regex: secrets/.*\.yaml$
       key_groups:
         - age:
             - *selenitic
             - *newhostname
             - *jonas
   ```

4. **Re-encrypt secrets for the new host**:
   ```bash
   sops updatekeys secrets/secrets.yaml
   sops updatekeys secrets/ssh.yaml
   ```
   You must run this on **both** encrypted files. This re-encrypts them so the new host can decrypt.

5. Commit and push (or transfer the updated files to the new machine).

### Phase 4: Create configuration files

You need to create/modify four files.

#### 4a. Add the host to `flake.nix`

Add an entry to the `hosts` object:
```nix
hosts = {
  amateria = { ... };
  selenitic = { ... };
  <hostname> = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.11";          # Match the NixOS release you installed with
    desktopEnvironment = "niri";     # "niri" or "kde"
    thermalZone = 5;                 # From Phase 2, or null to disable
  };
};
```

Add to `nixosConfigurations`:
```nix
nixosConfigurations = {
  amateria = mkNixosConfiguration "amateria" "jonas";
  selenitic = mkNixosConfiguration "selenitic" "jonas";
  <hostname> = mkNixosConfiguration "<hostname>" "jonas";
};
```

#### 4b. Create `hosts/<hostname>/default.nix`

Minimal host config (without NixOS-level sops):
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
    # "${nixosModules}/services/sops"        # Only if using NixOS-level secrets
    # "${nixosModules}/services/bitdefender"  # Optional
    # "${nixosModules}/services/clamav"       # Optional
  ];

  networking.hostName = hostname;

  system.stateVersion = hostConfig.stateVersion;
}
```

#### 4c. Copy `hardware-configuration.nix`

Place the file generated in Phase 2 at `hosts/<hostname>/hardware-configuration.nix`.

#### 4d. Create `home/jonas/<hostname>/default.nix`

This is the per-user per-host home config. The imports are the same across hosts, but host-specific settings (like monitor configuration for niri) go here:
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

  # Monitor configuration (niri only) — omit outputs you want auto-detected
  programs.niri.settings.outputs = {
    "eDP-1" = {
      mode = { width = 1920; height = 1080; refresh = 60.0; };
      scale = 1.0;
    };
  };

  programs.home-manager.enable = true;

  home.stateVersion = hostConfig.stateVersion;
}
```

### Phase 5: Build and deploy

1. **Stage all new files** — flake won't see untracked files without this:
   ```bash
   git add .
   ```

2. **Build and switch**:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

3. **Verify**, then commit and push:
   ```bash
   git add .
   git commit -m "Add <hostname> host configuration"
   git push
   ```

### Troubleshooting

**"error: getting status of '/nix/store/.../<filename>': No such file or directory"**
You forgot `git add .` — flake can't see untracked files.

**Sops decryption failure at activation**
- Home-manager sops: check that `~/.config/sops/age/keys.txt` exists and the public key is in `.sops.yaml`.
- NixOS-level sops: check that `/etc/ssh/ssh_host_ed25519_key` exists and the derived age key is in `.sops.yaml`. Ensure you ran `sops updatekeys` on all secret files.

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

### Switching desktop environments

Change `desktopEnvironment` in the host's entry in `flake.nix`:
```nix
<hostname> = {
  desktopEnvironment = "niri";  # or "kde"
};
```
Then rebuild. The system automatically loads the matching NixOS desktop module and conditionally imports the relevant home-manager desktop modules.

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
