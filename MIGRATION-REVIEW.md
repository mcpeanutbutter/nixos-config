# idk/ - Migration Review

Items from the old `idk/` config that haven't been migrated to the current setup.
Review and decide what to keep or scrap.

## Programs to Consider Adding

### lazygit
Git TUI with delta pager integration. Declarative home-manager config:
```nix
programs.lazygit = {
  enable = true;
  settings.git.paging = {
    colorArg = "always";
    pager = "delta --color-only --dark --paging=never";
  };
};
```

### k9s
Kubernetes TUI with custom hotkeys (Shift+1-7 to jump between pods, deployments, nodes, services, ingress, pulses, events). Headless/logoless UI.
```nix
programs.k9s = {
  enable = true;
  settings.k9s.ui = { headless = true; logoless = true; };
  hotKeys = {
    shift-1 = { shortCut = "Shift-1"; description = "Show pods"; command = "pods"; };
    shift-2 = { shortCut = "Shift-2"; description = "Show deployments"; command = "dp"; };
    # ... shift-3 through shift-7 for nodes, services, ingress, pulses, events
  };
};
```

### lazydocker
Docker TUI. Was installed as a package in `idk/` common home config. No dedicated module needed, just add `pkgs.lazydocker` to home packages.

### tmux
Terminal multiplexer with Vi keybinds, C-q prefix, smart Vim-aware pane switching (C-hjkl), v/s for splits, project selector (C-f). Catppuccin theming was available but commented out.

### starship
Custom shell prompt with Nerd Font symbols for K8s (with AWS EKS context alias parsing), Docker, Terraform, Go, Rust, Python, Java, etc. K8s context shown on right side. Would replace the current agnoster oh-my-zsh theme.
```nix
programs.starship = {
  enable = true;
  enableZshIntegration = true;
  settings = {
    add_newline = false;
    kubernetes = {
      disabled = false;
      symbol = "󱃾 ";
      format = "[$symbol$context( \($namespace\))]($style)";
      contexts = [{
        context_pattern = "arn:aws:eks:(?P<var_region>.*):(?P<var_account>[0-9]{12}):cluster/(?P<var_cluster>.*)";
        context_alias = "$var_cluster";
      }];
    };
    right_format = "$kubernetes";
  };
};
```

### atuin
Shell history manager with fuzzy search (skim mode), compact UI, secrets filtering, 25-line inline height. Up-arrow disabled to not conflict with zsh defaults.
```nix
programs.atuin = {
  enable = true;
  settings = {
    inline_height = 25; invert = true; records = true;
    search_mode = "skim"; secrets_filter = true; style = "compact";
  };
  flags = [ "--disable-up-arrow" ];
};
```

### gpg + gpg-agent
Full GPG config with SHA512 defaults, AES256 cipher, and gpg-agent as SSH agent (replaces ssh-agent). 24h cache TTL. Pinentry via gnome3.
```nix
programs.gpg = {
  enable = true;
  settings = {
    personal-digest-preferences = "SHA512";
    s2k-digest-algo = "SHA512";
    s2k-cipher-algo = "AES256";
    # ... extensive hardened settings
  };
};
services.gpg-agent = {
  enable = true;
  defaultCacheTtl = 86400;
  enableSshSupport = true;
  pinentry.package = pkgs.pinentry-gnome3;
};
```

### go
Golang dev environment with GOPATH and go/bin on PATH.
```nix
programs.go = { enable = true; goBin = "go/bin"; goPath = "go"; };
home.sessionPath = [ "$HOME/go/bin" ];
```

### krew
Kubectl plugin manager with `ctx` and `ns` plugins. Uses `home.activation` to auto-install/upgrade plugins on rebuild.
```nix
home.packages = [ pkgs.krew ];
home.sessionPath = [ "$HOME/.krew/bin" ];
home.activation.krew = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  export PATH="$HOME/.krew/bin:${pkgs.git}/bin:/usr/bin:$PATH";
  if [ -z "$(${pkgs.krew}/bin/krew list)" ]; then
    ${pkgs.krew}/bin/krew install ctx ns
  else
    ${pkgs.krew}/bin/krew upgrade
  fi
'';
```

### fastfetch
System info tool. Package is already installed but had a full custom display config with boxed layout, Nerd Font icons, showing OS/machine/kernel/packages/uptime/resolution/WM/DE/shell/terminal/CPU/GPU/memory/IPs.

### saml2aws
AWS SAML authentication tool with session vars (AWS_REGION=eu-west-1, session duration 3600s). Only relevant if you use AWS SAML-based auth.

### obs-studio
Screen recording / streaming. Simple enable via `programs.obs-studio.enable = true`.

---

## Services to Consider Adding

### cliphist
Clipboard history manager for Wayland. Single line enable:
```nix
services.cliphist.enable = true;
```
Would need a keybind in Niri to invoke it (e.g. `cliphist list | fuzzel --dmenu | cliphist decode | wl-copy`).

### easyeffects
Audio processing pipeline for mic input: RNNoise (AI noise suppression) -> Compressor (threshold -16dB, ratio 4:1, 9dB input gain) -> Limiter (-3dB threshold). Loads a "mic" preset automatically. Full JSON preset was declared inline via `xdg.configFile`.

### flatpak (via nix-flatpak)
Declarative Flatpak management. Was used to install Zoom. Requires adding `nix-flatpak` flake input. Useful for apps not in nixpkgs or that work better as Flatpaks.
```nix
services.flatpak = {
  enable = true;
  packages = [ "us.zoom.Zoom" ];
  uninstallUnmanaged = true;
};
```

---

## System-Level Features to Consider

### TLP (alternative to power-profiles-daemon)
Fine-grained laptop power management. You currently use `power-profiles-daemon` instead. TLP gives more control: CPU boost on/off per AC/battery, battery charge thresholds (85-90%), AMD GPU ABM levels, disk/PCIe/WiFi power savings, USB autosuspend. Trade-off: more complex, no GUI toggle.
```nix
services.tlp = {
  enable = true;
  settings = {
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;
    START_CHARGE_THRESH_BAT0 = 85;
    STOP_CHARGE_THRESH_BAT0 = 90;
    AMDGPU_ABM_LEVEL_ON_AC = 0;
    AMDGPU_ABM_LEVEL_ON_BAT = 3;
    # ... many more options
  };
};
# Requires: services.power-profiles-daemon.enable = false;
```

### Plymouth boot splash
Silent boot with splash screen. Was configured in `idk/` common with quiet kernel params and systemd-boot (instead of GRUB).
```nix
boot = {
  consoleLogLevel = 0;
  initrd.verbose = false;
  kernelParams = [ "quiet" "splash" "rd.udev.log_level=3" ];
  plymouth.enable = true;
};
# Also had: systemd.services.plymouth-quit-wait.enable = false; (for faster boot)
```

### v4l2loopback (virtual camera)
Kernel module for virtual camera device. Useful for OBS virtual camera or similar.
```nix
boot.kernelModules = [ "v4l2loopback" ];
boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
boot.extraModprobeConfig = ''
  options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
'';
```

---

## Misc Modules to Consider

### XDG directories and MIME associations
Creates standard XDG user directories (Desktop, Documents, Downloads, etc.) and sets default application associations for file types.
```nix
xdg = {
  enable = true;
  mimeApps = {
    enable = true;
    defaultApplications = lib.mkMerge [
      (config.lib.xdg.mimeAssociations [ pkgs.gnome-text-editor ])
      (config.lib.xdg.mimeAssociations [ pkgs.loupe ])
      (config.lib.xdg.mimeAssociations [ pkgs.totem ])
    ];
  };
  userDirs = { enable = true; createDirectories = true; };
};
```

---

## Missing CLI Utilities

Small tools that were in `idk/` home packages but aren't in the current config:

| Package | What it does |
|---|---|
| `jq` | JSON processor (essential for shell scripting) |
| `fd` | Fast `find` alternative |
| `du-dust` | Disk usage viewer with nice tree output |
| `dig` | DNS lookup tool (from `dnsutils`) |
| `unzip` | Archive extraction |
| `nh` | Nix helper CLI (nicer `nixos-rebuild` wrapper with diff output) |
| `python3` | Standalone Python interpreter |
| `tesseract` | OCR engine |

---

## Interesting Nix Patterns from idk/

### Flake registry + legacy channel sync
Registers all flake inputs as nix registry entries AND syncs them to `/etc/nix/path` for legacy `nix-channel` compatibility. Useful if you ever use `<nixpkgs>` style paths:
```nix
nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) (
  lib.filterAttrs (_: lib.isType "flake") inputs
);
nix.nixPath = [ "/etc/nix/path" ];
environment.etc = lib.mapAttrs' (name: value: {
  name = "nix/path/${name}";
  value.source = value.flake;
}) config.nix.registry;
```

### Faster boot via disabled systemd services
Disables two services that slow down boot:
```nix
systemd.services = {
  NetworkManager-wait-online.enable = false;  # Don't wait for network at boot
  plymouth-quit-wait.enable = false;          # Don't wait for plymouth to finish
};
```

### Home-manager activation for imperative tools (krew pattern)
Uses `home.activation` to run imperative install/upgrade commands during `home-manager switch`. Useful pattern for tools that manage their own plugins outside of Nix:
```nix
home.activation.krew = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  export PATH="$HOME/.krew/bin:${pkgs.git}/bin:/usr/bin:$PATH";
  if [ -z "$(${pkgs.krew}/bin/krew list)" ]; then
    ${pkgs.krew}/bin/krew install ctx ns
  else
    ${pkgs.krew}/bin/krew upgrade
  fi
'';
```

### Platform-conditional modules
Pattern for modules that should only activate on Linux (not Darwin/macOS):
```nix
{ lib, pkgs, ... }:
{
  config = lib.mkIf (!pkgs.stdenv.isDarwin) {
    # Linux-only configuration here
  };
}
```

### Inline config file generation
Declaring config files inline via `xdg.configFile` instead of separate files (used for easyeffects JSON preset). Keeps everything in one Nix file:
```nix
xdg.configFile."easyeffects/input/mic.json".text = ''{ ... }'';
```
