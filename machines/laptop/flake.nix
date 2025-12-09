{
  description = "Main workstation's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.06";
    # Import your consolidated software flake
    mySoftwareFlake = {
      url = "path:../../software"; # Relative path to your software flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    mySoftwareFlake,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations = {
      raspstation = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix # Your main configuration file
          # Import the consolidated module list from your software flake
          mySoftwareFlake.nixosModules.default
        ];
        # If your modules require special arguments, pass them here
        specialArgs = {
          # If modules within mySoftwareFlake.nixosModules.default need access to
          # mySoftwareFlake's other outputs (e.g., its packages.${system}.default),
          # you can pass the entire flake's outputs here.
          mySoftwareFlake = mySoftwareFlake;
        };
      };
    };
  };
}
