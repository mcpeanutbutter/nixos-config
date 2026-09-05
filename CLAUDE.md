# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository managed through Nix Flakes, supporting multiple hosts (`amateria`, `selenitic`, `spire`). Since all hosts share one repository, **always check the current hostname** (via `hostname` command) to determine which host you are on, and use the correct flake target (e.g. `.#selenitic`, `.#amateria`) accordingly. Never assume a specific host.

The configuration uses the [**dendritic pattern**](https://github.com/mightyiam/dendritic): every non-entry-point `.nix` file under `./modules/` is a flake-parts module of the top-level configuration, auto-imported via [`vic/import-tree`](https://github.com/vic/import-tree). `flake.nix` itself is ~25 lines — inputs + `flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)`. No `specialArgs` pass-through; modules read shared state from `config.*` (e.g. `config.user.username`, `config.hosts.<name>.theme`).

**Refactor activation in progress** (branch `refactor/dendritic`): the code is on the new layout, but `nixos-rebuild switch` hasn't been run on all hosts yet. See **[`/ACTIVATION-CHECKLIST.md`](./ACTIVATION-CHECKLIST.md)** — it's the single source of truth for what's left. If a session is unsure where the refactor stands, read that file first.

Top level:

- `/flake.nix`: 3-line `mkFlake + import-tree` entry point
- `/modules/`: the entire dendritic tree (see Directory Structure below)
- `/packages/`: custom packages (currently just `hatter-icon-theme`); referenced via overlay
- `/secrets/`: sops-encrypted secrets (git emails, ssh host config, etc.)

## Formatting

After modifying any `.nix` files, always run `nixfmt` on the changed files before committing or building. Example: `nixfmt path/to/file.nix`. This ensures consistent formatting across the repository.

## Dendritic pattern gotcha: always destructure module function args

When writing a `flake.modules.<class>.<bucket>` value as a function in a dendritic flake-parts module, **always destructure the args you use** (`{ pkgs, config, ... }: { ... }`). **Never** use a bare lambda with attribute access (`nixosArgs: { ... nixosArgs.pkgs.foo ... }`) — the module system may evaluate the function eagerly during imports-discovery (before `pkgs`/`config` are populated), and bare-arg attribute access fails with `error: attribute 'pkgs' missing`. Destructured args tell the module system upfront which args are required, so it defers evaluation correctly.

If a function-form module needs `imports = [ ... ]` in its body, wrap the function inside the outer attrset's `imports` instead:

```nix
# BAD — fails when evaluated through imports-discovery:
flake.modules.nixos.base = nixosArgs: {
  imports = [ inputs.foo.nixosModules.bar ];
  some.option = nixosArgs.pkgs.thing;  # ← attribute 'pkgs' missing
};

# GOOD:
flake.modules.nixos.base.imports = [
  inputs.foo.nixosModules.bar
  ({ pkgs, ... }: {
    some.option = pkgs.thing;
  })
];
```

If the inner function needs both the outer flake-parts `config` (`config.hosts.<name>...`) and the inner NixOS `config` (`config.networking.hostName`, ...), alias the outer one with a let-binding so the inner destructured `config` doesn't shadow it:

```nix
{ inputs, config, ... }:
let hostsCfg = config.hosts; in
{
  flake.modules.nixos.base.imports = [
    ({ pkgs, config, ... }: {
      foo = hostsCfg.${config.networking.hostName}.bar;
    })
  ];
}
```

Pattern reference: `mightyiam/infra/modules/style/stylix.nix`.

## Build and Development Commands

### System Configuration

```bash
# Build and switch to NixOS configuration (replace <hostname> with actual hostname)
sudo nixos-rebuild switch --flake .#<hostname>

# Test configuration without switching
sudo nixos-rebuild test --flake .#<hostname>

# Build configuration without activating
sudo nixos-rebuild build --flake .#<hostname>
```

### Home Manager Configuration

Home Manager is integrated as a NixOS module in this configuration, so it's automatically rebuilt when you run `nixos-rebuild switch`. There is no separate home-manager command needed.

### Flake Management

```bash
# Update all flake inputs to latest versions
nix flake update

# Update specific input
nix flake update nixpkgs-stable

# Show flake metadata and outputs
nix flake show

# Check flake for errors
nix flake check
```

## Architecture

### Flake Structure

**Key Flake Inputs**:

Nixpkgs inputs are always qualified — there is no bare `nixpkgs`. Most inputs
track stable; the unstable channel is pulled in selectively via the
`pkgs.unstable.*` overlay (see `modules/nixos/core/overlays.nix`).

- `nixpkgs-stable` (nixos-26.05): Primary package source; most inputs `follows` it
- `nixpkgs-unstable`: Unstable channel, exposed selectively as `pkgs.unstable.*` (nixd, vscodium, jetbrains-idea-oss, zed LSPs)
- `home-manager` (release-26.05): User-space configuration management, integrated as NixOS module
- `nix-vscode-extensions`: VSCode extensions (follows stable)
- `nixvim` (nixos-26.05): Neovim configuration framework (follows stable)
- `stylix`: System-wide theming (`nix-community/stylix` master — the `noctalia` v5 target only exists there; follows stable)
- `niri`: Niri compositor flake — provides the NixOS module and the build-time config validator; the niri *package* itself comes from `nixpkgs-stable` (`pkgs.niri`, currently 26.04, which has `background-effect` blur)
- `noctalia`: Noctalia v5, native Wayland desktop shell (bar, launcher, notifications, lock, wallpaper). HM module `programs.noctalia`, TOML settings in `modules/home/noctalia/`, launched as a systemd user service, driven via `noctalia msg <verb>`. Colors come from the stylix `noctalia` target. Follows stable (built from source).
- `sops-nix`: Secrets management (age-encrypted)
- `nixos-hardware`: Device-specific hardware optimizations (firmware updates, thermal management, SSD TRIM, GPU early KMS)

**Directory Structure**:

```
/
├── flake.nix                              # 3-line dendritic entry point
├── flake.lock
├── packages/
│   └── hatter-icon-theme/                 # custom KDE-dark icon theme
├── secrets/
│   ├── secrets.yaml                       # main sops file (git emails, BSC/VPN/GLPI creds)
│   └── ssh.yaml                           # separate sops file for work SSH host include
└── modules/                               # everything below is a flake-parts module
    ├── flake-parts.nix                    # imports flake-parts.flakeModules.modules
    ├── systems.nix                        # systems = [ "x86_64-linux" ]
    ├── home-manager.nix                   # wires HM-as-NixOS-module; base + work HM buckets
    ├── configurations/
    │   └── nixos.nix                      # configurations.nixos.<name>.module → flake.nixosConfigurations
    ├── meta/
    │   ├── user.nix                       # typed options.user (username, ssh, git, hashedPassword)
    │   └── hosts.nix                      # typed options.hosts.<name> (theme, hwmon/thermalZone, …)
    ├── hosts/
    │   ├── amateria/                      # Framework 16 — dual-boots Fedora; work machine
    │   │   ├── _hardware-configuration.nix    # nixos-generate-config output (underscore: skipped by import-tree)
    │   │   ├── hardware.nix               # thin wrapper importing _hardware-configuration.nix
    │   │   ├── data.nix                   # config.hosts.amateria.{theme, hwmon, hardwareModule, …}
    │   │   ├── imports.nix                # configurations.nixos.amateria.module.imports = [ base work ]
    │   │   ├── hostname.nix
    │   │   ├── state-version.nix
    │   │   ├── bootloader.nix             # GRUB extraEntry chainloading Fedora
    │   │   └── displays.nix               # niri.settings.outputs (eDP-1 + DP-3)
    │   ├── selenitic/                     # ThinkPad T480s — personal
    │   │   ├── _hardware-configuration.nix
    │   │   ├── hardware.nix data.nix imports.nix hostname.nix state-version.nix displays.nix
    │   └── spire/                         # AMD desktop — dual-boots CachyOS
    │       ├── _hardware-configuration.nix
    │       ├── hardware.nix data.nix imports.nix hostname.nix state-version.nix displays.nix
    │       ├── bootloader.nix             # GRUB extraEntries for CachyOS + CachyOS-LTS
    │       └── storage.nix                # encrypted data drive (boot.initrd.luks.devices."data" + fs mount)
    ├── nixos/
    │   ├── core/                          # foundational platform — writes flake.modules.nixos.base
    │   │   ├── audio.nix boot.nix fonts.nix locale.nix networking.nix
    │   │   ├── nix.nix overlays.nix packages.nix users.nix zsh.nix
    │   ├── services/                      # background services — flake.modules.nixos.base
    │   │   ├── openssh.nix printing.nix power.nix
    │   │   ├── sops.nix stylix.nix clamav.nix
    │   │   └── containers.nix docker.nix
    │   ├── desktop/
    │   │   └── niri.nix                   # niri-flake nixos module + greetd + xdg-portal + polkit + waybar/etc packages
    │   └── work/                          # flake.modules.nixos.work — only amateria imports
    │       └── bitdefender.nix vpn.nix glpi-agent.nix
    └── home/
        ├── core/                          # CLI/shell-oriented HM — flake.modules.homeManager.base
        │   ├── packages.nix session.nix sops.nix ssh.nix
        │   ├── git.nix zsh.nix starship.nix
        │   ├── bat.nix btop.nix claude-code.nix
        │   ├── direnv.nix eza.nix fzf.nix yazi.nix
        │   └── nixvim/                    # multi-file nixvim subtree (enable, keymaps, autocommands, lsp, plugins/*)
        ├── desktop/                       # niri compositor user side — flake.modules.homeManager.base
        │   ├── niri/                      # enable, keybindings, power-menu
        │   ├── waybar.nix waybar.css      # status bar + base16 stylix CSS
        │   ├── mako.nix swww.nix fuzzel.nix hyprlock.nix gtk.nix
        │   └── xdg.nix                    # GNOME Text Editor + Nemo + mimeApps defaults
        ├── programs/                      # GUI applications — flake.modules.homeManager.base
        │   ├── brave.nix obsidian.nix vesktop.nix
        │   ├── ghostty.nix kitty.nix vscode.nix zed.nix
        └── work/                          # flake.modules.homeManager.work
            └── git.nix ssh.nix sops.nix waybar.nix      # work git includes, ssh key, BSC widget
```

**Bucket convention**: every file in `modules/nixos/{core,services,desktop}/` writes to `flake.modules.nixos.base`. Every file in `modules/nixos/work/` writes to `flake.modules.nixos.work`. Same for `modules/home/` with `homeManager.base` / `homeManager.work`. Each host's `imports.nix` enumerates which buckets it pulls in.

**Underscore-prefix convention**: `import-tree` skips files/dirs starting with `_`. Used today for `_hardware-configuration.nix` files (the verbatim `nixos-generate-config` output, not a flake-parts module).

### Configuration Pattern

User and host data live as **typed top-level options** under `config.*`. Modules read them directly — no `specialArgs` pass-through.

**User configuration** (`modules/meta/user.nix`): declares `options.user` (typed submodule with `username`, `fullName`, `homeDirectory`, `hashedPassword`, `ssh.{personalPrivateKey,workPrivateKey}`, `git.{name,emailOverrides}`) and populates `config.user`. Git email addresses are NOT in this file — they live in sops and are pulled in at activation time via `programs.git.includes`.

**Host configuration** (`modules/meta/hosts.nix` + per-host `data.nix` files): declares `options.hosts.<name>` with `system`, `theme`, `stateVersion`, `subpixelLayout`, `thermalZone`, `hwmon`, `hardwareModule`. Each host's `modules/hosts/<host>/data.nix` populates one entry:

```nix
{ inputs, ... }:
{
  hosts.amateria = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.05";
    subpixelLayout = "none";
    hwmon = { path = "..."; input = "temp1_input"; };
    hardwareModule = inputs.nixos-hardware.nixosModules.framework-16-7040-amd;
  };
}
```

`thermalZone` and `hwmon` configure Waybar's temperature module. Use `thermalZone` on hosts with ACPI thermal zones (e.g. Intel laptops). Use `hwmon` on hosts where zones are absent (AMD desktops) — it maps to Waybar's `hwmon-path-abs` + `input-filename`. Both can be null.

**Bucket → host wiring** (`modules/hosts/<host>/imports.nix`): each host's imports.nix enumerates which buckets the host pulls in:

```nix
{ config, ... }:
{
  configurations.nixos.amateria.module = {
    imports = (with config.flake.modules.nixos; [ base work ]) ++ [
      config.hosts.amateria.hardwareModule
    ];
  };
}
```

`amateria` is the only host that imports `work`. selenitic and spire use `[ base ]` alone.

**Module-args access**: see "Dendritic pattern gotcha" above. Inside a function-form deferred module, destructure (`{ pkgs, config, ... }: ...`) — never use bare `nixosArgs:` with attribute access.

**Reading per-host data inside HM modules**: the outer flake-parts `config` has `config.hosts.<name>`, and the inner home-manager evaluation gets the NixOS-side state via `osConfig.networking.hostName`. Alias the outer config via let-binding to avoid shadowing:

```nix
{ config, ... }:
let hostsCfg = config.hosts; in
{
  flake.modules.homeManager.base.imports = [
    ({ config, osConfig, ... }: {
      programs.waybar.settings.mainBar.temperature.thermal-zone =
        hostsCfg.${osConfig.networking.hostName}.thermalZone;
    })
  ];
}
```

## Common Patterns

### Adding a new CLI / shell program (home-manager)

1. Create `modules/home/core/<name>.nix` (or `modules/home/programs/<name>.nix` if it's a GUI app).
2. Write `flake.modules.homeManager.base.programs.<name> = { ... };` (constant form) or `flake.modules.homeManager.base.imports = [ ({ pkgs, ... }: { programs.<name>.X = pkgs.Y; }) ];` if you need `pkgs`.
3. `git add` the new file — import-tree only sees git-tracked files.
4. `nixfmt path/to/file.nix` per the formatting convention.

### Adding a new NixOS service

1. Create `modules/nixos/services/<name>.nix`.
2. Write `flake.modules.nixos.base.services.<name> = { ... };`. If it's a work-only service, write to `flake.modules.nixos.work` instead.
3. If the service comes from a flake input, the function-form pattern looks like:
   ```nix
   { inputs, ... }:
   {
     flake.modules.nixos.base.imports = [
       inputs.foo.nixosModules.foo
       ({ pkgs, ... }: { services.foo.enable = true; })
     ];
   }
   ```

### Adding a new host

1. Pick a hostname; create `modules/hosts/<hostname>/`.
2. Run `nixos-generate-config --show-hardware-config` and save the output to `modules/hosts/<hostname>/_hardware-configuration.nix` (underscore prefix is mandatory — without it, import-tree will try to load the file as a flake-parts module and fail).
3. Create the scaffold (each is small; see existing hosts as templates):
   - `hardware.nix` — `configurations.nixos.<host>.module.imports = [ ./_hardware-configuration.nix ];`
   - `data.nix` — populates `config.hosts.<host>` with theme, stateVersion, hardwareModule, sensor data, etc.
   - `imports.nix` — `configurations.nixos.<host>.module.imports = (with config.flake.modules.nixos; [ base ]) ++ [ config.hosts.<host>.hardwareModule ];`
   - `hostname.nix` — `configurations.nixos.<host>.module.networking.hostName = "<host>";`
   - `state-version.nix` — reads from `config.hosts.<host>.stateVersion`.
   - `displays.nix` — `configurations.nixos.<host>.module.home-manager.users.${config.user.username}.programs.niri.settings.outputs = { ... };`
   - Optional: `bootloader.nix`, `storage.nix`, etc. for host-specific extras.
4. Check the [nixos-hardware module list](https://github.com/NixOS/nixos-hardware/blob/master/flake.nix) for a matching module and set `hardwareModule` in `data.nix`. For boards without a host-specific module, use an aggregating `{ imports = [ common-cpu-* common-gpu-* common-pc-ssd ]; }`.

### Custom package overlays

Overlays are inlined in `modules/nixos/core/overlays.nix`:

```nix
{ inputs, ... }:
{
  flake.modules.nixos.base.nixpkgs.overlays = [
    (final: _prev: { unstable = import inputs.nixpkgs-unstable { ... }; })
    (final: prev: { hatter-icon-theme = final.callPackage ../../../packages/hatter-icon-theme { }; })
    inputs.claude-code-nix.overlays.default
  ];
}
```

Add new overlays here. Custom packages live under `/packages/<name>/` (see `hatter-icon-theme` as a template).

## Desktop Environment

The configuration uses **Niri**, a scrollable-tiling Wayland compositor:

- Display manager: greetd with `noctalia-greeter` (`modules/nixos/noctalia/greeter.nix`); the shell syncs wallpaper + palette into it
- Compositor: Niri with custom keybindings and window rules
- Status bar: Waybar with custom styling
- Launcher: Fuzzel
- Notifications: Mako
- Terminal: Ghostty (configured with custom theming)
- Features: Rounded corners, themed window borders, focus follows mouse

### Common Desktop Features

- Audio: PipeWire with ALSA and PulseAudio compatibility
- Keyboard layout: US with altgr-intl variant
- Theming: Stylix for system-wide theme management (Material Darker)

### CachyOS Dual-Boot (Spire)

Spire dual-boots NixOS + CachyOS. NixOS GRUB directly boots the CachyOS kernel from the CachyOS ESP (no chainloading — chainloading systemd-boot from GRUB doesn't work because systemd-boot misidentifies the ESP).

**Disk layout:**
- `sda1` (vfat, `FC6A-791C`): NixOS ESP (GRUB lives here)
- `sda2` (LUKS): NixOS root
- `nvme2n1p1` (vfat, `0F06-0878`): CachyOS ESP (kernel + initramfs)
- `nvme2n1p2` (LUKS, `52464ea2-...`): CachyOS root (decrypted UUID: `db42ec0c-...`)

**If CachyOS GRUB entry stops working** (e.g. after CachyOS kernel package rename):
1. Boot into NixOS (default GRUB entry)
2. Mount CachyOS ESP: `sudo mount /dev/nvme2n1p1 /mnt`
3. Check current kernel filenames: `ls /mnt/vmlinuz* /mnt/initramfs*`
4. Check systemd-boot entries: `cat /mnt/loader/entries/*.conf`
5. Update `modules/hosts/spire/bootloader.nix` `boot.loader.grub.extraEntries` with the correct kernel/initramfs filenames and boot args from step 4
6. Rebuild: `sudo nixos-rebuild switch --flake .#spire`
7. Unmount: `sudo umount /mnt`

**Alternative boot method:** CachyOS can always be booted via the UEFI firmware temporary boot device menu (F12/F8/Del at POST) by selecting `nvme2n1` — this works independently of GRUB.

## Git Workflow

This is a Git-tracked flake. Changes must be staged (`git add .`) for flake commands to recognize new files. Flake lock file (`flake.lock`) pins input versions for reproducibility.

## Key Features

### Modularity

- Dendritic pattern — every non-entry-point `.nix` under `./modules/` is a flake-parts module, auto-imported via `vic/import-tree`.
- Host wiring lives in `modules/hosts/<host>/imports.nix`; bucket modules under `modules/nixos/` and `modules/home/` write to `flake.modules.{nixos,homeManager}.{base,work}`.
- Adding a new host is a small `modules/hosts/<host>/` directory; adding a feature is a single new `.nix` file (no central import list to update — import-tree finds it automatically).

### Hardware Support

Each host imports device-specific modules from the `nixos-hardware` flake:

- **amateria** (Framework 16): `framework-16-7040-amd` — fwupd, fprintd, SSD TRIM, AMD iGPU early KMS, touchpad, bluetooth
- **selenitic** (ThinkPad T480s): `lenovo-thinkpad-t480s` — throttled thermal management, SSD TRIM, Intel microcode
- **spire** (AMD desktop): `common-cpu-amd` + `common-gpu-amd` + `common-pc-ssd` — AMD microcode, GPU early KMS + 32-bit support, SSD TRIM
- Latest kernel (`linuxPackages_latest`) on all hosts for best hardware compatibility

### Development Tools

Common packages include:

- Cloud: Google Cloud SDK, kubectl, kind, clusterctl
- Languages: JDK, Python (poetry), Node.js tooling
- Infrastructure: Terraform/OpenTofu, Ansible
- Editors: VSCode, Neovim (nixvim), JetBrains IDEA
- Terminals: Ghostty, Kitty
- Containers: Docker (rootless), Podman

### Security

- Sops-nix for secrets management (age-encrypted, decrypted at activation time)
- Git email addresses stored in sops secrets, not in Nix source files
- BitDefender and ClamAV antivirus (configured in earlier commits)
- Rootless Docker for container isolation

## Notes

- System state version: 25.05 (amateria, selenitic) / 25.11 (spire), declared in each host's `modules/hosts/<host>/data.nix`
- User hashedPassword (yescrypt) is in `modules/meta/user.nix`
- Unfree packages are allowed
- Experimental features enabled: nix-command, flakes
- Auto-optimise Nix store enabled
