{
  description = "Lanzaboote Secure Boot Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, ... }: {
    nixosModules.default = { pkgs, lib, config, ... }: {
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
    };
  };
}
