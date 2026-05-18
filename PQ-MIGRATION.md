# Post-Quantum sops Migration Plan

Migrate `secrets/*.yaml` from classical age (X25519) recipients to hybrid post-quantum (X25519 + ML-KEM-768) recipients, so that captured ciphertexts cannot be decrypted by a future CRQC ("harvest now, decrypt later").

## Current state

`.sops.yaml` lists four recipients:

| Recipient | Source | Where the private key lives |
|---|---|---|
| `age19z6...` (amateria) | Derived from `/etc/ssh/ssh_host_ed25519_key` via `ssh-to-age` | On the host, decrypted by `sops-nix` activation |
| `age15kv...` (selenitic) | Same | Same |
| `age1lug...` (spire) | Same | Same |
| `age1dlc...` (jonas) | Standalone age key | `~/.config/sops/age/keys.txt` on each machine |

Wired in:

- `modules/nixos/services/sops.nix:7` — `sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];`
- `modules/home/core/sops.nix:13` — `sops.age.keyFile = "${user.homeDirectory}/.config/sops/age/keys.txt";`

Tooling versions in current nixpkgs: `sops` 3.12.1, `age` 1.3.1 — both PQ-capable (sops dispatches on the `age1pq1` / `AGE-SECRET-KEY-PQ-1` prefixes).

## The host-key problem

The `ssh-to-age` path only works for X25519. There is no way to derive a hybrid PQ age identity from an SSH ed25519 host key — ML-KEM-768 is a lattice scheme with no relationship to Curve25519. Migrating to PQ therefore **requires giving up the "host SSH key is the sops key" pattern** and provisioning a dedicated PQ age key on each host instead.

This is the biggest cost of the migration; the rest is mechanical.

## Plan

### Phase 1 — personal key (low risk, do first)

The `age1dlc...` (jonas) recipient is the easiest path and exercises the tooling end-to-end before touching host keys.

1. Generate a PQ key on the machine where decryption already works:
   ```bash
   age-keygen -pq -o ~/.config/sops/age/keys-pq.txt
   age-keygen -y ~/.config/sops/age/keys-pq.txt
   ```
   Save the printed `age1pq1...` recipient.

2. Add the new recipient to `.sops.yaml` *alongside* (not replacing) the old `&jonas` anchor:
   ```yaml
   - &jonas-pq age1pq1...
   ```
   List it under `key_groups[0].age` so existing files can be re-wrapped to it.

3. Re-wrap data keys:
   ```bash
   sops updatekeys secrets/secrets.yaml
   sops updatekeys secrets/ssh.yaml
   ```

4. Distribute `keys-pq.txt` to every machine you decrypt from (selenitic, spire, amateria). Out-of-band — do *not* commit it.

5. Point sops at the new key file. Either:
   - Replace the path in `modules/home/core/sops.nix:13` with `keys-pq.txt`, **or**
   - Concatenate both keys into `keys.txt` (sops accepts multiple identities and tries each) during the transition.

6. Verify a decrypt with only the PQ key present, then remove `&jonas` from `.sops.yaml`, run `sops updatekeys` once more to drop the classical wrapping, commit.

### Phase 2 — host keys (per host)

Repeat for amateria, selenitic, spire. Do **one host at a time** and verify activation before moving on — if you brick `sops-nix` decryption on a host, services that depend on it (git email override, ssh include, etc.) will fail at next rebuild.

Per host:

1. **Bootstrap a PQ key on the host.** sops-nix can't decrypt a key it needs to bootstrap itself, so generate it locally on the host:
   ```bash
   sudo mkdir -p /var/lib/sops-nix
   sudo age-keygen -pq -o /var/lib/sops-nix/key.txt
   sudo chmod 600 /var/lib/sops-nix/key.txt
   sudo age-keygen -y /var/lib/sops-nix/key.txt
   ```
   Copy the printed `age1pq1...` recipient back to your workstation.

2. **Add the new recipient to `.sops.yaml`** as a parallel anchor (`&amateria-pq`, etc.), keeping the old `&amateria` in place for now. Add it to `key_groups[0].age`.

3. **Re-wrap:**
   ```bash
   sops updatekeys secrets/secrets.yaml
   sops updatekeys secrets/ssh.yaml
   ```

4. **Switch the host module** (`modules/nixos/services/sops.nix`) from SSH-key derivation to the new key file. Two options:

   - **Per-host override** (recommended during migration so one rebuild only affects one host):
     ```nix
     # in modules/hosts/<host>/sops.nix or similar
     configurations.nixos.<host>.module.sops.age = {
       keyFile = "/var/lib/sops-nix/key.txt";
       sshKeyPaths = lib.mkForce [ ];
     };
     ```
   - **Global swap** (do after all three hosts have a PQ key on disk): edit `modules/nixos/services/sops.nix` to use `keyFile = "/var/lib/sops-nix/key.txt";` and drop `sshKeyPaths`.

5. **Rebuild and verify:**
   ```bash
   sudo nixos-rebuild test --flake .#<host>
   systemctl status sops-nix
   ls /run/secrets/  # sanity check
   ```
   If decryption fails, `sops.age.sshKeyPaths` is still in the closure as a fallback during the transition — but only if you didn't `mkForce` it away. Roll back with `nixos-rebuild switch --rollback` if needed.

6. Once stable on all three hosts, remove the classical host anchors (`&amateria`, `&selenitic`, `&spire`) from `.sops.yaml`, run `sops updatekeys` a final time, and commit.

### Phase 3 — cleanup

- Confirm `.sops.yaml` contains only `age1pq1...` recipients.
- Confirm `sops -d secrets/secrets.yaml` works on each host *and* on your workstation using only PQ keys.
- Remove any remaining `sshKeyPaths` references and the now-unused classical key files (`~/.config/sops/age/keys.txt` if you kept `keys-pq.txt` separate).
- Re-encrypt the underlying payload of each secrets file once for good measure (`sops -r -i secrets/*.yaml`) so the data key itself is freshly generated under the PQ-only recipient set.
- Document the new bootstrap procedure in `CLAUDE.md` (the "adding a new host" section currently relies on the SSH-host-key shortcut).

## Costs and caveats

- **`.sops.yaml` size.** Each PQ recipient is ~2 KB versus ~60 B today. Four recipients = ~8 KB of YAML. Cosmetic but worth knowing.
- **`secrets/*.yaml` metadata size.** Each wrapped data key grows from ~50 B to ~1.5 KB base64 (ML-KEM-768 ciphertext is 1088 B). Still trivial.
- **No `ssh-to-age` shortcut anymore.** New hosts will need explicit PQ key generation as a bootstrap step.
- **Key rotation is now a real operation** — you can no longer "rotate" the sops key by regenerating the SSH host key. The PQ key file is the source of truth and must be backed up out-of-band.
- **Recovery.** If `/var/lib/sops-nix/key.txt` is lost on a host, that host can't decrypt secrets until a new key is provisioned and `sops updatekeys` is re-run. Worth keeping the personal `age1pq1...` recipient permanently so you can always re-wrap from your workstation.

## Threat-model sanity check

This migration only matters if the threat is *long-term confidentiality* of these specific secrets — i.e. you assume an adversary may capture `secrets/*.yaml` today and decrypt later. For this repo's contents (work git emails, VPN/BSC creds, SSH host include) that's a real but mild concern; the secrets rotate naturally on a timescale shorter than any plausible CRQC arrival. Reasonable to do for hygiene; not urgent.
