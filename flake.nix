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
      # TODO: move this to a module
      config = {
        allowUnfreePredicate = pkg:
          builtins.elem (pkgs.lib.getName pkg) [
            "steam"
            "steam-original"
            "steam-unwrapped"
            "steam-run"
            "google-chrome"
            "discord"
          ];
      };
    };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./machines/laptop/configuration.nix
          ./machines/laptop/hardware.nix
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
          {
            system.stateVersion = "25.05";
            wsl.enable = true;
            nix.settings.experimental-features = ["nix-command" "flakes"];
            environment = {
              variables.EDITOR = "nvim";
              systemPackages = [
                mySystem.packages.${system}.standardApps
              ];
            };
          }
        ];
      };
    };

    devShells.${system}.default = mySystem.devShells.${system}.default;

    packages.${system}.raspEnv = {
      default = mySystem.packages.${system}.default;
    };
  };
}
