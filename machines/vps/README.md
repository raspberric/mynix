# Contabo VPS Deployment

This host targets a Contabo Cloud VPS installed with `nixos-anywhere` from an
existing Linux installation or Contabo's rescue system. Deployment is
intentionally blocked until `instance.nix` contains values verified on the
actual server.

Run workstation commands from the repository root.

## 1. Create The VPS

Create an `x86_64` Contabo VPS with at least 2 GiB RAM and a temporary Ubuntu
installation. In the Contabo panel:

- Record the exact IPv4 address, prefix length, and gateway.
- Configure the temporary system to accept your public SSH key for root.

Choose one local SSH key pair for both installation and final `xpo` access, set
the paths, and test SSH:

```bash
export SERVER_IPV4="YOUR_SERVER_IPV4"
export SSH_KEY="$HOME/.ssh/id_ed25519"
ssh -i "$SSH_KEY" "root@$SERVER_IPV4"
```

If Contabo initially provides only a root password, install the same public key
once with `ssh-copy-id -i "$SSH_KEY.pub" "root@$SERVER_IPV4"`.
Using one key for both stages is normal: its private half remains on the
workstation, and final NixOS authorizes only the public half for `xpo`. Protect
the private key with a passphrase and use separate keys for different admins or
workstations rather than separate installation stages.

## 2. Check Kexec Support

`nixos-anywhere` normally replaces temporary Ubuntu by booting its installer
with `kexec`. Run the non-destructive preflight:

```bash
nix run .#vps-kexec-probe -- \
  -i "$SSH_KEY" \
  "root@$SERVER_IPV4"
```

The target needs an `x86_64` Linux kernel with kexec enabled, no active kernel
lockdown, at least 1.5 GiB RAM excluding swap, root or passwordless sudo access,
and the required archive/session utilities. The probe checks these known
requirements but does not load a kernel, so the actual kexec phase remains the
final compatibility test.

If Ubuntu fails preflight, boot Contabo rescue mode and rerun the probe there.
Rescue mode is optional when Ubuntu passes.

## 3. Collect Instance Facts

Collect firmware, disk, and network values over SSH and write them to
`machines/vps/instance.nix`:

```bash
nix run .#vps-facts -- \
  -i "$SSH_KEY" \
  "root@$SERVER_IPV4"
```

If the VPS has multiple physical disks, the command refuses to guess. Choose a
reported whole-disk ID and rerun with `--disk /dev/disk/by-id/...`.
The command replaces `machines/vps/instance.nix` and always writes
`deploymentReady = false` so installation remains blocked until review.

## 4. Complete Instance Configuration

Review generated `machines/vps/instance.nix` against the VPS and Contabo panel:

- Set `disk` to the intended whole-disk `/dev/disk/by-id/...` path.
- Set `bootMode` to `bios` or `uefi`.
- Set `interface` to the default network interface.
- Set the exact IPv4 address, prefix length, and gateway.
- Set `deploymentReady = true` only after verifying every value.

SSH keys are managed separately in `machines/vps/authorized-keys.nix` and are
not part of `instance.nix`.

Verify selected disk on temporary Ubuntu/rescue system before deployment:

```bash
DISK="/dev/disk/by-id/PASTE_GENERATED_DISK_ID"
readlink -f "$DISK"
lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,MODEL,SERIAL,MOUNTPOINTS
lsblk -dn -o NAME,PATH,SIZE,TYPE,MODEL,SERIAL "$(readlink -f "$DISK")"
```

Resolved device must be intended VPS disk, have `TYPE` equal to `disk`, and
match expected Contabo disk size/model. Use whole-disk ID, never a `-partN`
partition ID. Installation erases this device completely.

Use the Contabo panel as source of truth for IPv4 configuration. Do not infer
the prefix or gateway from the address. Initial deployment uses IPv4 only; add
IPv6 after IPv4 SSH and the assigned `/64` route work correctly.

Assertions prevent a build while placeholders remain.

## 5. Prepare Sudo Password

The installed SSH service accepts keys only. User `xpo` still needs a password
for `sudo`. In one terminal, create its temporary yescrypt hash:

```bash
nix run .#vps-password-hash
```

The script prompts for the password, prints its protected temporary directory,
and waits. Leave it running. In a second terminal, copy the `export secret_dir`
command printed by the script and set the server address again:

```bash
export secret_dir="/tmp/PATH_PRINTED_BY_SCRIPT"
export SERVER_IPV4="YOUR_SERVER_IPV4"
export SSH_KEY="$HOME/.ssh/id_ed25519"
```

Run validation and installation from the second terminal. After installation,
return to the first terminal and press `Ctrl+C`; the script deletes the secret
directory and exits. If installation fails, leave it running while retrying.
Never add the directory or hash to Git.

## 6. Validate

```bash
nix flake check
nix build .#nixosConfigurations.vps.config.system.build.toplevel
```

Both commands must complete without failed assertions. Commit reviewed
configuration before starting destructive installation.

## 7. Install And Reboot

Keep Contabo console or rescue access available, then run:

```bash
nix run .#nixos-anywhere -- \
  --flake .#vps \
  --target-host "root@$SERVER_IPV4" \
  -i "$SSH_KEY" \
  --extra-files "$secret_dir"
```

This erases and repartitions selected disk, installs NixOS, installs its
bootloader, and reboots the VPS automatically.

## 8. Verify NixOS

After reboot, confirm the new SSH host fingerprint through the Contabo console.
On the workstation, remove the obsolete Ubuntu/rescue host key from local
`known_hosts`, then connect to NixOS as `xpo`:

```bash
ssh-keygen -R "$SERVER_IPV4"
ssh -i "$SSH_KEY" "xpo@$SERVER_IPV4"
```

Inside the VPS, validate the configured sudo password and check for failed
services, network configuration, routes, and disk usage:

```bash
sudo --validate
systemctl --failed
ip address
ip route
df -h
```

Enroll Tailscale with `sudo tailscale up`. Verify another fresh SSH login before
ending rescue or console access.

## 9. Post-Install Security Hardening

After verifying the NixOS firewall and a fresh SSH login, optionally create a
Contabo firewall as an external defense-in-depth layer and assign it to the VPS:

- Allow TCP port `22` for SSH.
- Allow ICMP for network diagnostics.
- Allow UDP port `41641` for direct Tailscale connections.
- Drop other unsolicited inbound traffic.

Keep Contabo console access open while applying these rules, then verify another
SSH connection before closing it. UDP `41641` is optional because Tailscale can
fall back to DERP relays.

## Rebuilding From The VPS

To apply config changes directly on the VPS without going through the workstation:

```bash
# From the repo root on the VPS
nix run .#vps-facts -- --local
# Review instance.nix, set deploymentReady = true
sudo nixos-rebuild switch --flake .#vps
```

`vps-facts --local` reads hardware facts from the running system instead of
over SSH. The resulting `instance.nix` is identical in format to the
workstation-generated one.

## Recovery And Maintenance

- Boot Contabo rescue mode if normal SSH fails.
- Keep source code pushed off-host; off-site workstation backups remain pending.
- Update `flake.lock` on a trusted machine, build successfully, then deploy.
- Do not enable blind automatic flake updates on the VPS.
- Provider snapshots are short-term rollback aids, not durable backups.
