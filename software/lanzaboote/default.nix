{
  pkgs,
  lanzaboote,
  lib,
  ...
}: {
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  # Ensure sbctl is available for managing Secure Boot keys
  environment.systemPackages = [
    pkgs.sbctl
  ];

  # Lanzaboote replaces the default systemd-boot module.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
