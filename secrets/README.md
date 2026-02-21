# Secrets Management with sops-nix

## How sops-nix works — two types of keys

**Host keys** (one per machine, for decryption at boot):
- NixOS does NOT auto-generate SSH host keys — `services.openssh` must be enabled (our common module does this)
- Even with openssh enabled, the keys are only generated when the service first activates
- This creates a chicken-and-egg problem: sops-nix needs the host key to decrypt secrets, but the key doesn't exist until after the first successful build
- **Solution**: Manually generate the host key before the first build (see bootstrap steps below)
- sops-nix converts the SSH ed25519 key to an age key at boot to decrypt secrets
- The public key goes into `.sops.yaml` so secrets are encrypted *for* that host

**User key** (for editing secrets):
- Stored at `~/.config/sops/age/keys.txt`
- Only needed on machines where you run `sops secrets/secrets.yaml` to edit
- You can copy the same key to multiple machines, or generate one per machine
- Not needed for the system to boot/decrypt — that uses the host key

## Bootstrapping a new host

This is required once per host. There is no way around it — sops-nix needs a host key to decrypt secrets, and that key must exist before the first `nixos-rebuild switch`.

1. **Generate the SSH host key manually** (openssh will reuse it when it activates):
   ```bash
   sudo mkdir -p /etc/ssh
   sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   ```

2. **Derive the host's age public key**:
   ```bash
   nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
   ```

3. **Generate a user age key** (if you don't have one yet):
   ```bash
   mkdir -p ~/.config/sops/age
   nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"
   ```

4. **Add both public keys to `.sops.yaml`** (at the repo root)

5. **Create/update the encrypted secrets file**:
   ```bash
   # New file:
   nix-shell -p sops age --run 'sops secrets/secrets.yaml'
   # Or if secrets already exist and you're adding a new host:
   nix-shell -p sops age --run 'sops updatekeys secrets/secrets.yaml'
   ```

6. **Stage and build**:
   ```bash
   git add .
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

After the first successful build, openssh takes over managing the host key. Subsequent rebuilds just work.

## Adding a new host later

1. Install NixOS on the new machine
2. **Manually generate the SSH host key** (it won't exist yet):
   ```bash
   sudo mkdir -p /etc/ssh
   sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   ```
3. Derive the age public key:
   ```bash
   nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
   ```
4. On any machine with the user age key:
   - Add the new host's public key to `.sops.yaml`
   - Run `sops updatekeys secrets/secrets.yaml` (re-encrypts for the new host)
   - Commit + push
5. On the new machine: `git pull && sudo nixos-rebuild switch --flake .#<hostname>`

## Key reference

| Key | Path | Purpose |
|-----|------|---------|
| Host private (manual, then managed by openssh) | `/etc/ssh/ssh_host_ed25519_key` | Decrypts secrets at boot — never leaves the machine |
| User private (manual) | `~/.config/sops/age/keys.txt` | Lets you edit/view secrets via `sops` CLI |
| Public keys | Listed in `.sops.yaml` | Determine who can decrypt `secrets/secrets.yaml` |

## Current keys

| Host/User | Age public key |
|-----------|---------------|
| selenitic | `age15kvpw8grrnjn3e609rju5e0p5f3fs4gradxr36dh9mksl25g3vssz54v43` |
| jonas | `age1dlcau98tlksg4xcg32rae7cyrhdxky8gtlagjhma5xprwfqqks2q7hs6k6` |

## Notes

- `secrets/secrets.yaml` is encrypted and safe to commit publicly
- Only hosts/users listed in `.sops.yaml` can decrypt
- If a host is reinstalled, its SSH key changes — re-derive the age key, update `.sops.yaml`, and `sops updatekeys`
