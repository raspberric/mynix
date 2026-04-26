{
  description = "Raspberry nix wsl config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    mySystem = {
      url = "path:./software";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "path:./software/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixos-wsl,
    mySystem,
    lanzaboote,
    ...
  }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./machines/laptop/configuration.nix
          ./machines/laptop/hardware.nix
          ./software/gui/gaming.nix
          ./software/common/sessionVariables.nix
          ./software/devshells/nix-ld.nix
          lanzaboote.nixosModules.default
        ] ++ (builtins.attrValues mySystem.nixosModules) ++ [
          {
            environment = {
              systemPackages = [
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
          ./software/common/sessionVariables.nix
          {
            system.stateVersion = "25.05";
            wsl.enable = true;
            nix.settings.experimental-features = ["nix-command" "flakes"];
            environment = {
              systemPackages = [
                mySystem.packages.${system}.standardApps
              ];
            };
          }
        ];
      };
    };

    devShells.${system} = mySystem.devShells.${system};

    packages.${system} = {
      raspEnv = mySystem.packages.${system}.default;
      default = mySystem.packages.${system}.default;
    };
  };
}
