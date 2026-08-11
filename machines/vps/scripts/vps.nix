{pkgs, ...}: {
  vps-kexec-probe = import ./vps-kexec-probe.nix {inherit pkgs;};
  vps-facts = import ./vps-facts.nix {inherit pkgs;};
  vps-password-hash = import ./vps-password-hash.nix {inherit pkgs;};
}
