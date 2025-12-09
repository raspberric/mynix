{
  description = "Main workstation's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.06";
    mvim = {
      url = "path:../../software/common/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
  }: {
    nixosConfigurations = {
      raspstation = nixpkgs.lib.nixosSystem {
        modules = [
          ./hardware.nix
          ./configuration.nix
          ../../software/common
          ../../software/gui
        ];
      };
    };
  };
}
