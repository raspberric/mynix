{
  description = "Raspberry nix wsl config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    mySystem = {
      url = "path:./software";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    mySystem,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          {
            environment = {
              variables.EDITOR = "neovim";
              systemPackages = [
                pkgs.google-chrome
                mySystem.packages.${system}.default
              ];
            };
          }
        ];
      };
      wsl = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "25.05";
            wsl.enable = true;
            nix.settings.experimental-features = ["nix-command" "flakes"];
            environment = {
              variables.EDITOR = "vim";
              systemPackages = [
                pkgs.git
                mySystem.packages.${system}.default
              ];
            };
          }
        ];
      };
    };

    packages.${system}.raspEnv = {
      default = mySystem.packages.${system}.default;
    };
  };
}
