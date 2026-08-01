{pkgs, ...}:
pkgs.writeShellApplication {
  name = "vps-kexec-probe";
  runtimeInputs = [pkgs.openssh];
  text = ''
    if [ "$#" -eq 0 ]; then
      echo "Usage: vps-kexec-probe [ssh-options] <user@host>"
      exit 1
    fi

    ssh "$@" bash -s < ${./vps-kexec-probe-remote.sh}
  '';
}
