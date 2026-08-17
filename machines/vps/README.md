# Contabo VPS Deployment

This configuration has two separate workflows:

- Use `nixos-anywhere` once to erase the temporary OS and install NixOS.
- Use `nixos-rebuild` afterward, either from the workstation or on the VPS.

`machines/vps/instance.nix` contains reviewed machine facts and must remain
committed with `deploymentReady = true` after installation. SSH public keys live
in `machines/vps/authorized-keys.nix`. Password hashes never enter Git or the
Nix store.

Run workstation commands from the repository root unless stated otherwise.

## Initial Installation

### 1. Connect To Temporary Linux

Create an `x86_64` Contabo VPS with at least 2 GiB RAM and a temporary Ubuntu
installation. Record its exact IPv4 address, prefix length, and gateway from the
Contabo panel.

Use one local SSH key pair for temporary root access and final `xpo` access:

```bash
export SERVER_IPV4="YOUR_SERVER_IPV4"
export SSH_KEY="$HOME/.ssh/id_ed25519"
```

If Contabo initially provides only a root password, install the public key once:

```bash
ssh-copy-id -i "$SSH_KEY.pub" "root@$SERVER_IPV4"
```

Confirm key-based access:

```bash
ssh -i "$SSH_KEY" "root@$SERVER_IPV4"
```

Exit that SSH session before continuing with workstation commands.

### 2. Check Kexec Support

The temporary Linux system normally boots the nixos-anywhere installer with
`kexec`. Run the non-destructive preflight from the workstation:

```bash
nix run .#vps-kexec-probe -- \
  -i "$SSH_KEY" \
  "root@$SERVER_IPV4"
```

If Ubuntu fails, boot Contabo rescue mode and rerun the probe. Rescue mode is
not required when temporary Ubuntu passes.

### 3. Generate `instance.nix`

Collect initial firmware, disk, and network observations over SSH:

```bash
nix run .#vps-facts -- \
  -i "$SSH_KEY" \
  "root@$SERVER_IPV4"
```

This replaces `machines/vps/instance.nix` and writes
`deploymentReady = false`. It is an initial provisioning helper, not part of
routine rebuilds.

If multiple physical disks exist, select one explicitly:

```bash
nix run .#vps-facts -- \
  --disk /dev/disk/by-id/WHOLE_DISK_ID \
  -i "$SSH_KEY" \
  "root@$SERVER_IPV4"
```

### 4. Review Destructive Values

Review `machines/vps/instance.nix` manually:

- Confirm `disk` is the intended whole-disk `/dev/disk/by-id/...` path.
- Confirm `bootMode` is `bios` or `uefi`.
- Confirm `interface` is the default network interface.
- Replace observed IPv4 values with exact Contabo panel values when they differ.
- Confirm your public key exists in `machines/vps/authorized-keys.nix`.

Verify the selected disk against the temporary host:

```bash
DISK="$(nix eval --raw --expr '(import ./machines/vps/instance.nix).disk')"
ssh -i "$SSH_KEY" "root@$SERVER_IPV4" \
  "readlink -f '$DISK'; lsblk -dn -o NAME,PATH,SIZE,TYPE,MODEL,SERIAL '$DISK'"
```

The result must have `TYPE` equal to `disk`, match the expected Contabo disk,
and not end in `-partN`.

Set `deploymentReady = true` only after every value is verified. Commit and push
the reviewed configuration before installation so the VPS can later clone the
same source. Public IP addresses and SSH public keys are not secrets.

### 5. Prepare Sudo Password

The final SSH service accepts keys only. User `xpo` still needs a password for
`sudo`. In terminal 1 on the workstation, run:

```bash
nix run .#vps-password-hash
```

The helper creates a protected temporary tree, prints an `export secret_dir=...`
command, and waits. Leave it running.

In terminal 2, copy the printed export and restore the other variables:

```bash
export secret_dir="/tmp/PATH_PRINTED_BY_SCRIPT"
export SERVER_IPV4="YOUR_SERVER_IPV4"
export SSH_KEY="$HOME/.ssh/id_ed25519"
```

### 6. Validate And Install

From terminal 2:

```bash
nix flake check
nix build .#nixosConfigurations.vps.config.system.build.toplevel
```

Both commands must pass. Keep Contabo console or rescue access available, then
run the destructive installation:

```bash
nix run .#nixos-anywhere -- \
  --flake .#vps \
  --target-host "root@$SERVER_IPV4" \
  -i "$SSH_KEY" \
  --extra-files "$secret_dir"
```

This erases the selected disk, installs the bootloader and NixOS, then reboots.

### 7. Verify NixOS

Through the Contabo console, display the new server fingerprints:

```bash
for key in /etc/ssh/ssh_host_*_key.pub; do
  ssh-keygen -E sha256 -lf "$key"
done
```

On the workstation, remove the obsolete temporary-OS host key and connect:

```bash
ssh-keygen -R "$SERVER_IPV4"
ssh -i "$SSH_KEY" "xpo@$SERVER_IPV4"
```

Compare the fingerprint before accepting it. Then run these checks inside VPS:

```bash
sudo --validate
sudo test -s /etc/nixos/secrets/xpo-password-hash
sudo stat -c '%U:%G %a %n' /etc/nixos/secrets/xpo-password-hash
systemctl --failed
ip -4 address
ip -4 route
getent ahostsv4 cache.nixos.org
findmnt /
findmnt /boot
df -h
```

Expected secret ownership and mode are `root:root 600`. Enroll Tailscale with
`sudo tailscale up`, then verify one more fresh SSH login.

After successful installation, return to terminal 1 and press `Ctrl+C`. The
password helper deletes its temporary secret tree.

## Rebuild From Workstation

This is the preferred routine for a small VPS: configuration builds locally,
then its closure is copied and activated remotely. Root SSH remains disabled;
activation uses `xpo` and asks for the sudo password.

The VPS config makes `xpo` a trusted Nix user so it can import custom paths
built on the workstation. Nix trusted users have root-equivalent control through
the daemon; this is appropriate only because `xpo` is the sole administrator.

From the workstation repository:

```bash
export SERVER_IPV4="YOUR_SERVER_IPV4"
export SSH_KEY="$HOME/.ssh/id_ed25519"
export NIX_SSHOPTS="-i $SSH_KEY -o IdentitiesOnly=yes"

nixos-rebuild build --flake .#vps

nixos-rebuild dry-activate \
  --flake .#vps \
  --target-host "xpo@$SERVER_IPV4" \
  --ask-sudo-password

nixos-rebuild switch \
  --flake .#vps \
  --target-host "xpo@$SERVER_IPV4" \
  --ask-sudo-password
```

For bootloader or network changes, keep Contabo console access open and use
`nixos-rebuild boot` instead of `switch`, then reboot deliberately.

The password hash already exists on the VPS. Do not run the password helper or
pass `--extra-files` again for normal rebuilds.

An existing VPS that predates the trusted-user setting must apply it once from
inside VPS before workstation pushes can succeed:

```bash
cd "$HOME/config"
git pull --ff-only
sudo nixos-rebuild switch --flake .#vps
```

## Rebuild On The VPS

The repository is public, but nixos-anywhere installs only the built system, not
the source checkout. Connect from the workstation:

```bash
ssh -i "$SSH_KEY" "xpo@$SERVER_IPV4"
```

Then clone the repository inside VPS:

```bash
git clone https://github.com/raspberric/mynix.git "$HOME/config"
cd "$HOME/config"
```

For each later update, push the reviewed commit from the workstation, then run
inside VPS:

```bash
cd "$HOME/config"
git pull --ff-only

nixos-rebuild build --flake .#vps
nixos-rebuild dry-activate --flake .#vps --sudo
nixos-rebuild switch --flake .#vps --sudo
```

Do not rerun `vps-facts`: committed `instance.nix` is the machine definition,
not data to regenerate during updates.

## Rebuild Safety

Both rebuild methods evaluate the same `nixosConfigurations.vps` and produce the
same result when they use the same commit and `flake.lock`.

Normal `nixos-rebuild` does not format or repartition disks. Disko is destructive
only when invoked explicitly, including through the initial nixos-anywhere Disko
phase. Changing `disk-config.nix` alone also does not migrate an existing disk.

Never use `nixos-anywhere` for routine updates.

## Post-Install Hardening

After verifying NixOS firewall and SSH, optionally assign a Contabo firewall as
an external defense-in-depth layer:

- Allow TCP port `22` for SSH.
- Allow ICMP for diagnostics.
- Optionally allow UDP port `41641` for direct Tailscale connections.
- Drop other unsolicited inbound traffic.

Keep Contabo console access open while applying provider firewall rules, then
verify another SSH connection. Tailscale can use DERP relays without UDP 41641.

## Recovery And Maintenance

- Boot Contabo rescue mode if normal SSH fails.
- Keep `/etc/nixos/secrets/xpo-password-hash`; every activation reads it.
- A manual `passwd` change is overwritten on the next activation unless this
  hash file is updated too.
- Keep reviewed source pushed off-host and back up application data separately.
- Update `flake.lock` on a trusted machine, build successfully, then deploy.
- Do not enable blind automatic flake updates on VPS.
- Provider snapshots are short-term rollback aids, not durable backups.

## Open Design

Open Design runs as a native, hardened NixOS service instead of a container so
it can launch the Nix-packaged Codex and OpenCode executables directly. Its
daemon listens only on loopback. The frontend accepts the hostname preserved by
Tailscale Serve, but its port remains closed in the NixOS firewall. Tailscale
Serve provides private HTTPS access; no Open Design TCP port is publicly opened.

### Configure Tailscale HTTPS

Enable MagicDNS and HTTPS certificates in the Tailscale admin console. Ensure
tailnet policy grants only intended users or devices access to TCP port 443 on
this VPS. Do not enable Funnel for this endpoint.

Get the tailnet DNS name from the Tailscale DNS settings, then replace
`tailscaleDnsName` in `machines/vps/instance.nix`. Use the name ending in
`.ts.net`, such as `boar-beta.ts.net`, without a scheme, port, or trailing slash.
The VPS machine name from `networking.hostName` is prepended automatically.

After deployment, Tailscale Serve exposes Open Design at:

```text
https://HOSTNAME.TAILNET.ts.net
```

Check services from the VPS:

```bash
systemctl status open-design.service
systemctl status open-design-web.service
systemctl status open-design-tailscale-serve.service
tailscale serve status
curl --fail http://127.0.0.1:7457/api/health
curl --fail http://127.0.0.1:5174/
```

### Use The CLI

The `od` command runs as the dedicated `open-design` identity so CLI changes
and MCP configuration use the same projects and state as the system service:

```bash
sudo od --help
sudo od project list --json
sudo od plugin list --json
```

The Open Design package intentionally takes precedence over the coreutils
octal-dump program that is also named `od`.

### Authenticate Codex

Codex authentication belongs to the dedicated `open-design` service identity,
not user `xpo`. Device authentication uses ChatGPT subscription access and
stores refreshable credentials under the protected Open Design data directory:

```bash
sudo open-design-codex login --device-auth
sudo open-design-codex login status
```

Select `Codex CLI` and an available subscription model in Open Design. The live
model list comes from the authenticated Codex CLI.

### Authenticate OpenCode Zen

Even zero-cost Zen models require an OpenCode account and API key. Create the
key at `https://opencode.ai/auth`, then authenticate the service identity:

```bash
sudo open-design-opencode auth login --provider opencode
sudo open-design-opencode auth list
sudo open-design-opencode models opencode
```

Select `OpenCode` and `opencode/deepseek-v4-flash-free` in Open Design. Free
model availability is temporary, and prompts submitted to free models may be
used for model improvement. Do not send confidential material through them.

### Data And Recovery

All Open Design state, managed projects, agent configuration, and agent login
credentials live under `/var/lib/open-design`. Back up that directory only to
encrypted storage. Stop `open-design.service` before taking a filesystem-level
backup so its SQLite database and project state are consistent.

Normal HTML previews work through Tailscale Serve. Some upstream features are
intentionally restricted to a browser on daemon localhost, including powered
WebGL/Worker previews, live-artifact refresh, and connector credential
management. For those features, open a tunnel through Tailscale from the
workstation:

```bash
export OPEN_DESIGN_HOST="xpo-vps.boar-beta.ts.net"

ssh -N \
  -L 127.0.0.1:5174:127.0.0.1:5174 \
  -L localhost:7457:127.0.0.1:7457 \
  -o ExitOnForwardFailure=yes \
  -i "$SSH_KEY" \
  "xpo@$OPEN_DESIGN_HOST"
```

Keep that command running and open `http://127.0.0.1:5174`. Port 5174 serves
the frontend and proxies normal API requests. Port 7457 lets powered previews
reach the daemon through their required alternate `localhost` origin. SSH
travels over the Tailscale network; no public-IP connection is involved. The
browser sends loopback origins, satisfying Open Design's localhost checks
without weakening them for every tailnet request.
