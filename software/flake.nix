{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    mvim = {
      url = "path:./common/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-esp-dev,
    mvim,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
        permittedInsecurePackages = [
          "electron-36.9.5"
          "python3.13-ecdsa-0.19.1"
        ];
        allowUnfreePredicate = pkg:
          builtins.elem (pkgs.lib.getName pkg) [
            "google-chrome"
            "vscode"
            "android-studio"
            "android-studio-stable"
            "android-sdk-tools"
            "android-sdk-platform-tools"
            "android-sdk-cmdline-tools"
            "android-sdk-build-tools"
            "platform-tools"
            "build-tools"
            "android-sdk-emulator"
            "cmdline-tools"
            "tools"
            "claude-code"
          ];
      };
    };

    standardApps = pkgs.symlinkJoin {
      name = "standard apps";
      paths = with pkgs; [
        posting
        mvim.packages.${system}.fedev
        podman-compose
      ];
    };
  in {
    nixosModules = {
      podmanModule = ./modules/podman.nix;
    };

    packages.${system} = {
      inherit standardApps;

      default = pkgs.symlinkJoin {
        name = "mySystem";
        paths = [
          standardApps
          guiApps
        ];
      };
    };

    devShells.${system} = {
      vscode = pkgs.mkShell {
        buildInputs = [pkgs.vscode];
      };

      cdev = import ./devshells/c.nix {
        inherit pkgs nixpkgs-esp-dev;
        vimFlavor = mvim.packages.${system}.cdev;
      };

      godev = import ./devshells/go.nix {
        inherit pkgs;
        vimFlavor = mvim.packages.${system}.godev;
      };

      rndev = import ./devshells/react-native.nix {inherit pkgs;};

      default = pkgs.mkShell {
        buildInputs = [standardApps];
        shellHook = ''
          echo "Welcome to the rice fields MF!"
        '';
      };
    };
  };
}
