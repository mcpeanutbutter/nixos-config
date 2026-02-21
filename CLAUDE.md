# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository managed through Nix Flakes, currently configured for the `amateria` machine (Framework 16 laptop).

**Important**: The repository contains old/experimental code in `old/` and `idk/` directories that is NOT currently in use. The configuration has been completely restructured into a modular architecture using:

- `/flake.nix`: Main flake definition with host configurations
- `/users/`: Per-user configuration (imported by flake.nix)
- `/hosts/`: Per-host NixOS configurations
- `/home/`: Per-user Home Manager configurations
- `/modules/nixos/`: Reusable NixOS modules (system-level)
- `/modules/home-manager/`: Reusable Home Manager modules (user-level)
- `/overlays/`: Package overlays for custom versions
- `/secrets/`: Sops-encrypted secrets (git emails, API keys, etc.)

**Ignore** the `old/` and `idk/` directories when working with the current configuration.

## Build and Development Commands

### System Configuration

```bash
# Build and switch to NixOS configuration
sudo nixos-rebuild switch --flake .#amateria

# Test configuration without switching
sudo nixos-rebuild test --flake .#amateria

# Build configuration without activating
sudo nixos-rebuild build --flake .#amateria
```

### Home Manager Configuration

Home Manager is integrated as a NixOS module in this configuration, so it's automatically rebuilt when you run `nixos-rebuild switch`. There is no separate home-manager command needed.

### Flake Management

```bash
# Update all flake inputs to latest versions
nix flake update

# Update specific input
nix flake update nixpkgs

# Show flake metadata and outputs
nix flake show

# Check flake for errors
nix flake check
```

## Architecture

### Flake Structure

**Key Flake Inputs**:

- `nixpkgs` (nixos-unstable): Primary package source
- `nixpkgs-stable` (nixos-25.05): Stable packages
- `home-manager`: User-space configuration management, integrated as NixOS module
- `nix-vscode-extensions`: VSCode extensions
- `nixvim`: Neovim configuration framework
- `nixgl`: OpenGL wrapper for non-NixOS systems (not currently used)
- `stylix`: System-wide theming
- `niri`: Niri compositor flake for Wayland window management

**Directory Structure**:

```
/
├── flake.nix                           # Main flake definition with host configs
├── flake.lock                          # Locked input versions
├── users/                              # Per-user configurations (imported by flake.nix)
│   └── jonas/
│       └── default.nix                 # User config (password, ssh, git settings)
├── hosts/                              # Per-host configurations
│   └── amateria/
│       ├── default.nix                 # Host-specific NixOS configuration
│       └── hardware-configuration.nix  # Hardware-specific settings
├── home/                               # Per-user home-manager configurations
│   └── jonas/
│       └── amateria/
│           └── default.nix             # User+host specific home configuration
├── secrets/                            # Sops-encrypted secrets
│   └── secrets.yaml                    # Encrypted secrets (git emails, etc.)
├── modules/
│   ├── nixos/                          # NixOS modules (system-level)
│   │   ├── common/                     # Common system configuration
│   │   ├── desktop/
│   │   │   ├── kde/                    # KDE Plasma 6 desktop module
│   │   │   └── niri/                   # Niri compositor module
│   │   ├── programs/
│   │   │   └── docker/                 # Docker configuration
│   │   └── services/
│   │       └── stylix/                 # Stylix theming service
│   └── home-manager/                   # Home Manager modules (user-level)
│       ├── common/                     # Common user configuration & packages
│       ├── desktop/
│       │   ├── mako/                   # Notification daemon (for Niri)
│       │   ├── niri/                   # Niri compositor user config
│       │   └── waybar/                 # Waybar status bar (for Niri)
│       └── programs/                   # Per-program configurations
│           ├── direnv/
│           ├── eza/
│           ├── fuzzel/                 # Application launcher (for Niri)
│           ├── fzf/
│           ├── ghostty/                # Terminal emulator
│           ├── git/
│           ├── kitty/                  # Terminal emulator
│           ├── nixvim/                 # Neovim configuration
│           ├── ssh/
│           ├── vscode/
│           ├── yazi/                   # File manager
│           ├── zed/
│           └── zsh/
├── overlays/                           # Package overlays
│   └── default.nix
├── old/                                # OLD/UNUSED: Previous flat configuration
└── idk/                                # OLD/UNUSED: Earlier modular experiments
```

### Configuration Pattern

The flake uses a modular pattern with user and host definitions:

**User Configuration** (in `users/${username}/default.nix`, imported by `flake.nix`):

```nix
{
  username = "jonas";
  fullName = "Jonas Schmoele";
  homeDirectory = "/home/jonas";
  hashedPassword = "$y$...";  # yescrypt hash
  ssh = { ... };
  git = {
    name = "Jonas Schmoele";
    # Directory -> sops key suffix mapping for per-project email overrides
    emailOverrides = {
      personal = "~/projects/personal";
      work = "~/projects/work";
    };
  };
}
```

Git email addresses are stored in sops-encrypted `secrets/secrets.yaml` (not in Nix files) and injected via `programs.git.includes` pointing to sops-decrypted secret files.

**Host Configuration** (in `flake.nix`):

```nix
hosts = {
  amateria = {
    system = "x86_64-linux";
    theme = "material-darker";
    stateVersion = "25.05";
    desktopEnvironment = "niri";  # Options: "kde" or "niri"
  };
};
```

**NixOS Configuration Builder**:
The `mkNixosConfiguration` function creates a NixOS system configuration for a given hostname and username, automatically:

- Loading host-specific config from `./hosts/${hostname}`
- Loading user-specific home-manager config from `./home/${username}/${hostname}`
- Passing `userConfig` and `hostConfig` to both NixOS and Home Manager modules
- Providing module path variables (`nixosModules` and `nhModules`) for importing

**Special Arguments Available Throughout**:

NixOS modules receive:

- `inputs`: All flake inputs
- `outputs`: Flake outputs (including overlays)
- `hostname`: Current hostname
- `userConfig`: User configuration object
- `hostConfig`: Host configuration object
- `nixosModules`: Path to NixOS modules directory

Home Manager modules receive:

- `inputs`: All flake inputs
- `outputs`: Flake outputs
- `vscode-extensions`: VSCode extensions from nix-vscode-extensions
- `userConfig`: User configuration object
- `hostConfig`: Host configuration object
- `nhModules`: Path to Home Manager modules directory

### Configuration Files

**hosts/amateria/default.nix**: Host-specific NixOS configuration that:

- Imports hardware configuration
- Imports modular NixOS components based on `hostConfig.desktopEnvironment`
- Sets hostname via the `hostname` parameter

**modules/nixos/common/default.nix**: Common system-level configuration including:

- Bootloader (GRUB with EFI)
- Latest kernel (`linuxPackages_latest`)
- Networking (NetworkManager)
- PipeWire audio
- User account creation (from `userConfig`)
- Docker with rootless mode (imported separately)
- Container support (Podman)
- Locale: en_US.UTF-8 / de_AT.UTF-8
- System packages and fonts
- Nix flake support and overlays

**modules/nixos/desktop/**: Desktop environment modules:

- `kde/`: KDE Plasma 6 desktop with SDDM and Wayland support
- `niri/`: Niri scrollable-tiling Wayland compositor with polkit, portals, and GREETD

**home/jonas/amateria/default.nix**: User+host specific home configuration that:

- Imports common home-manager configuration
- Conditionally imports desktop modules based on `hostConfig.desktopEnvironment`

**modules/home-manager/common/default.nix**: Common user-space configuration including:

- Imports all program configurations
- User packages (development tools, applications, etc.)
- Session variables
- Common program enables (bat, btop, git, etc.)

**modules/home-manager/programs/**: Individual program configurations for git, zsh, nixvim, vscode, ghostty, sops, etc.

**modules/home-manager/desktop/**: Desktop-related user modules:

- `niri/`: Niri compositor configuration with keybindings, layouts, window rules, themed borders/corners
- `waybar/`: Status bar configuration for Niri
- `mako/`: Notification daemon configuration
- `fuzzel/`: Application launcher (referenced in common imports)

## Common Patterns

### Adding New Applications

1. **User-level application**: Create a new `.nix` file in `modules/home-manager/programs/` and import it in `modules/home-manager/common/default.nix`
2. **System-level application**: Create a new `.nix` file in `modules/nixos/programs/` and import it in the appropriate host configuration or common module
3. **Desktop-specific**: Add to `modules/home-manager/desktop/` or `modules/nixos/desktop/` and ensure conditional imports based on `hostConfig.desktopEnvironment`

### Adding a New Host

1. Create new directory `hosts/${hostname}/` with `default.nix` and `hardware-configuration.nix`
2. Add host configuration to the `hosts` object in `flake.nix`
3. Create corresponding home configuration at `home/${username}/${hostname}/default.nix`
4. Register in `nixosConfigurations` using `mkNixosConfiguration "${hostname}" "${username}"`

### Switching Desktop Environments

Change `desktopEnvironment` in the host configuration (in `flake.nix`):

```nix
hosts = {
  amateria = {
    desktopEnvironment = "niri";  # or "kde"
  };
};
```

The system will automatically:

- Load the appropriate NixOS desktop module from `modules/nixos/desktop/`
- Conditionally import relevant home-manager desktop modules in `home/jonas/amateria/default.nix`

### Custom Package Overlays

The repository uses overlays in `overlays/default.nix` to override package versions. These are automatically applied via `modules/nixos/common/default.nix`. Example pattern:

```nix
{
  stable-packages = final: _prev: {
    # Import stable packages with prefix
    stable = import inputs.nixpkgs-stable { ... };
  };

  custom-packages = final: prev: {
    package-name = prev.package-name.overrideAttrs (oldAttrs: {
      version = "new-version";
      src = ...;
    });
  };
}
```

## Desktop Environments

The configuration supports two desktop environments, switchable via `hostConfig.desktopEnvironment`:

### Niri (Current: Active)

**Niri** is a scrollable-tiling Wayland compositor with dynamic workspaces:

- Display manager: GREETD with `agreety` greeter
- Compositor: Niri with custom keybindings and window rules
- Status bar: Waybar with custom styling
- Launcher: Fuzzel
- Notifications: Mako
- Terminal: Ghostty (configured with custom theming)
- Features: Rounded corners, themed window borders, focus follows mouse

### KDE Plasma 6 (Available)

**KDE Plasma 6** desktop environment with:

- Display manager: SDDM (Wayland enabled)
- Full-featured desktop with extensive configuration options
- To activate: Set `desktopEnvironment = "kde"` in `hosts.amateria` in `flake.nix`

### Common Desktop Features

- Audio: PipeWire with ALSA and PulseAudio compatibility
- Keyboard layout: US with altgr-intl variant
- Theming: Stylix for system-wide theme management (Material Darker)

## Git Workflow

This is a Git-tracked flake. Changes must be staged (`git add .`) for flake commands to recognize new files. Flake lock file (`flake.lock`) pins input versions for reproducibility.

## Key Features

### Modularity

- Completely modular architecture separating concerns
- Host-specific configurations in `hosts/`
- User+host specific home configurations in `home/`
- Reusable NixOS modules in `modules/nixos/`
- Reusable Home Manager modules in `modules/home-manager/`
- Easy to add new hosts or users

### Hardware Support

- Framework 16 laptop (using nixos-hardware flake)
- Latest kernel for best hardware compatibility

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

- System state version: 25.05
- User hashedPassword is defined in `users/${username}/default.nix` (yescrypt)
- Unfree packages are allowed
- Experimental features enabled: nix-command, flakes
- Auto-optimise Nix store enabled
- Current branch: `complete-rework` (architectural overhaul)
