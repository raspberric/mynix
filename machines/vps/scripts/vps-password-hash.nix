{pkgs, ...}:
pkgs.writeShellApplication {
  name = "vps-password-hash";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.mkpasswd
  ];
  text = ''
    secret_dir="$(mktemp -d)"
    cleanup() {
      rm -rf "$secret_dir"
      printf '\nDeleted %s\n' "$secret_dir"
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP

    install -d -m 700 "$secret_dir/etc/nixos/secrets"

    if ! (umask 077; mkpasswd -m yescrypt > "$secret_dir/etc/nixos/secrets/xpo-password-hash"); then
      exit 1
    fi

    printf '\nSecret directory: %s\n' "$secret_dir"
    printf 'In another terminal, run: export secret_dir=%q\n' "$secret_dir"
    printf 'Keep this process running during installation. Press Ctrl+C afterward.\n'

    while true; do
      sleep 3600
    done
  '';
}
