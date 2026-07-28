# Contabo VPS Deployment

This host targets a Contabo Cloud VPS installed from its rescue system with
`nixos-anywhere`. Deployment is intentionally blocked until `instance.nix`
contains values verified on the actual server.

## 1. Configure Contabo Firewall

Create and assign a Contabo firewall before installation. Its permanent default
rule drops all other inbound traffic.

- Allow TCP port 22 from `Any`.
- Allow ICMP from `Any`.
- Allow UDP port 41641 from `Any` for direct Tailscale connectivity.

## 2. Inspect Rescue System

Boot Contabo's rescue system and connect as root. Record facts before touching
the disk:

```bash
test -d /sys/firmware/efi && printf 'UEFI\n' || printf 'BIOS\n'
lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,MODEL,SERIAL,TRAN,MOUNTPOINTS
ls -l /dev/disk/by-id/
ip -br link
ip -4 address
ip -4 route
ip -6 address
ip -6 route
command -v kexec
sysctl kernel.kexec_load_disabled
```

Use the Contabo Customer Panel as the source of truth for the IPv4 address,
prefix length, and gateway. Do not infer the prefix or gateway from the address.
Initial deployment uses IPv4 only; add IPv6 after IPv4 SSH and the assigned `/64`
route have been verified.

## 3. Complete Instance Configuration

Edit `machines/vps/instance.nix`:

- Set `disk` to the verified whole-disk `/dev/disk/by-id/...` path.
- Set `bootMode` to `bios` or `uefi` from the firmware check.
- Set `interface` to the observed VirtIO interface name.
- Set the exact IPv4 address, prefix length, and gateway.
- Add at least one complete SSH public key to `sshKeys`.
- Set `deploymentReady = true` only after checking every value.

The disk is erased during deployment. Assertions deliberately prevent a build
while placeholders remain.

## 4. Prepare Sudo Password

The final SSH service accepts keys only. The `xpo` account requires a separate
password for sudo. Create a temporary root-only tree that nixos-anywhere will
copy into the installed system:

```bash
secret_dir="$(mktemp -d)"
trap 'rm -rf "$secret_dir"' EXIT
install -d -m 700 "$secret_dir/etc/nixos/secrets"
nix shell nixpkgs#mkpasswd -c sh -c \
  'umask 077; mkpasswd -m yescrypt > "$1/etc/nixos/secrets/xpo-password-hash"' \
  sh "$secret_dir"
```

Enter the password interactively. Never add this directory or password hash to
Git. The shell removes the temporary directory when it exits.

## 5. Validate

Run local evaluation before installation:

```bash
nix flake check
nix build .#nixosConfigurations.vps.config.system.build.toplevel
```

Both commands must complete without failed assertions.
Commit the reviewed configuration before running the destructive installation.

## 6. Install

Keep Contabo rescue access available throughout installation:

```bash
nix run .#nixos-anywhere -- \
  --flake .#vps \
  --target-host root@SERVER_IPV4 \
  --extra-files "$secret_dir"
```

The target disk is repartitioned and all existing data is destroyed.

## 7. Verify

After reboot, open a new connection without closing rescue or console access:

```bash
ssh xpo@SERVER_IPV4
sudo --validate
systemctl --failed
ip address
ip route
df -h
```

Then enroll Tailscale with `sudo tailscale up`. Verify another fresh SSH login
before ending rescue access.

## Recovery And Maintenance

- Boot Contabo rescue mode if normal SSH fails.
- Keep source code pushed off-host; off-site workstation backups remain pending.
- Update `flake.lock` on a trusted machine, build successfully, then deploy.
- Do not enable blind automatic flake updates on the VPS.
- Provider snapshots are short-term rollback aids, not durable backups.
