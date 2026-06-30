{
  description = "Raspberry nix wsl config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    mvim = {
      url = "path:./software/common/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencodeFlake = {
      url = "github:anomalyco/opencode?rev=f06b78751e08ca38dc50da7f7ca1c408e6ad6298";
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    nixos-wsl,
    lanzaboote,
    nixpkgs-esp-dev,
    mvim,
    opencodeFlake,
    nixpkgs-unstable,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [mvim.overlays.default];
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
    tools = import ./software/tools.nix {inherit pkgs;};
    dev = import ./software/dev.nix {inherit pkgs;};
    gui = import ./software/gui.nix {inherit pkgs;};
    opencode = opencodeFlake.packages.${system}.default;
    unstable = import nixpkgs-unstable {inherit system;};
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./machines/laptop/configuration.nix
          ./machines/laptop/hardware.nix
          ./software/gaming.nix
          ./software/common/sessionVariables.nix
          ./software/devshells/nix-ld.nix
          (import ./software/lanzaboote {
            inherit pkgs lanzaboote;
            lib = pkgs.lib;
          })
          (import ./software/modules/virtualization.nix {inherit pkgs unstable;})
          {
            environment.systemPackages = [tools dev gui pkgs.mvim pkgs.fedev pkgs.pydev opencode (import ./software/common/srb-id-pkcs11-chrome.nix {inherit pkgs;})];
          }
        ];
      };
      wsl = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-wsl.nixosModules.default
          ./software/common/sessionVariables.nix
          ./software/devshells/nix-ld.nix
          {
            nixpkgs.hostPlatform = system;
            system.stateVersion = "25.05";
            wsl.enable = true;
            nix.settings.experimental-features = ["nix-command" "flakes"];
            environment.systemPackages = [tools dev pkgs.mvim];
          }
        ];
      };

      vps = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-wsl.nixosModules.default
          ./software/common/sessionVariables.nix
          ./software/devshells/nix-ld.nix
          {
            nixpkgs.hostPlatform = system;
            system.stateVersion = "25.05";
            nix.settings.experimental-features = ["nix-command" "flakes"];
            environment.systemPackages = [tools dev pkgs.mvim];
          }
        ];
      };
    };

    packages.${system} = {
      inherit tools dev gui;
      default = pkgs.symlinkJoin {
        name = "default";
        paths = [tools dev gui];
      };
    };

    devShells.${system} = {
      vscode = pkgs.mkShell {
        buildInputs = [pkgs.vscode];
      };

      cdev = import ./software/devshells/c.nix {
        inherit pkgs nixpkgs-esp-dev;
        vimFlavor = pkgs.cdev;
      };

      godev = import ./software/devshells/go.nix {
        inherit pkgs;
        vimFlavor = pkgs.godev;
      };

      rndev = import ./software/devshells/react-native.nix {inherit pkgs;};

      default = pkgs.mkShell {
        buildInputs = [pkgs.mvim];
        shellHook = ''
          echo "Welcome to the rice fields MF!"
        '';
      };
    };
  };
}
