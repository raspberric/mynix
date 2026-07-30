{
  description = "NixOS system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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
    herdrFlake.url = "github:ogulcancelik/herdr/v0.7.1";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixos-wsl,
    lanzaboote,
    nixpkgs-esp-dev,
    mvim,
    opencodeFlake,
    nixpkgs-unstable,
    herdrFlake,
    disko,
    nixos-anywhere,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        mvim.overlays.default
        (_final: _prev: {
          opencode = opencodeFlake.packages.${system}.default;
        })
      ];
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
    tools = import ./software/tools.nix {inherit pkgs;};
    vpsTools = import ./software/tools.nix {
      inherit pkgs;
      desktopTools = false;
    };
    dev = import ./software/dev.nix {inherit pkgs;};
    gui = import ./software/gui.nix {inherit pkgs;};
    unstable = import nixpkgs-unstable {inherit system;};
    herdrConfigured = import ./software/common/herdr/herdr.nix {
      inherit pkgs;
      herdr = herdrFlake.packages.${system}.default;
    };
    nixpkgsConfig.nixpkgs.config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          nixpkgsConfig
          ./machines/laptop/configuration.nix
          ./software/modules/k3d.nix
          ./software/modules/optimize.nix
          ./software/modules/tailscale.nix
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
            environment.systemPackages = [tools dev gui pkgs.mvim pkgs.fedev pkgs.pydev (import ./software/common/srb-id-pkcs11-chrome.nix {inherit pkgs;}) herdrConfigured];
          }
        ];
      };
      wsl = nixpkgs.lib.nixosSystem {
        modules = [
          nixpkgsConfig
          nixos-wsl.nixosModules.default
          ./machines/wsl/configuration.nix
          ./software/modules/optimize.nix
          ./software/common/sessionVariables.nix
          ./software/devshells/nix-ld.nix
          {
            nixpkgs.hostPlatform = system;
            environment.systemPackages = [tools dev pkgs.mvim];
          }
        ];
      };

      vps = nixpkgs.lib.nixosSystem {
        specialArgs.vpsInstance = import ./machines/vps/instance.nix;
        modules = [
          nixpkgsConfig
          disko.nixosModules.disko
          ./machines/vps/configuration.nix
          ./machines/vps/contabo.nix
          ./machines/vps/disk-config.nix
          ./software/common/sessionVariables.nix
          ./software/modules/optimize.nix
          ./software/modules/tailscale.nix
          ./software/devshells/nix-ld.nix
          {
            nixpkgs.hostPlatform = system;
            environment.systemPackages = [vpsTools dev herdrConfigured pkgs.neovim];
          }
        ];
      };
    };

    packages.${system} = {
      inherit tools dev gui;
      nixos-anywhere = nixos-anywhere.packages.${system}.default;
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
