{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    mvim = {
      url = "path:./common/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    mvim,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
        permittedInsecurePackages = [
          "electron-36.9.5"
        ];
        allowUnfreePredicate = pkg:
          builtins.elem (pkgs.lib.getName pkg) [
            "steam"
            "steam-original"
            "steam-unwrapped"
            "steam-run"
            "google-chrome"
            "discord"
            "discord-custom"
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
          ];
      };
    };
    gitConfigured = import ./common/git.nix {inherit pkgs;};
    lazygitConfigured = import ./common/lazygit.nix {inherit pkgs;};
    tmuxConfigured = import ./common/tmux.nix {inherit pkgs;};
    ghosttyConfigured = import ./gui/ghostty.nix {inherit pkgs;};
    discordConfigured = import ./gui/discord.nix {inherit pkgs;};
    nxConfigured = import ./common/nx/default.nix {inherit pkgs;};
    opencodeConfigured = import ./common/opencode/opencode.nix {inherit pkgs;};
    pkillOnPort = import ./scripts/pkillOnPort.nix {inherit pkgs;};
    okular = import ./gui/okular.nix {inherit pkgs;};
    srbIdPkcs11 = import ./common/srb-id-pkcs11.nix {inherit pkgs;};

    standardApps = pkgs.symlinkJoin {
      name = "standard apps";
      paths = with pkgs;
        [
          gitConfigured
          lazygitConfigured
          tmuxConfigured
          tldr
          nodejs_24
          pnpm
          xclip
          ripgrep
          opencodeConfigured
          pkillOnPort
          posting
          srbIdPkcs11
        ]
        ++ (builtins.attrValues mvim.packages.${system});
    };

    guiApps = pkgs.symlinkJoin {
      name = "gui apps";
      paths = with pkgs; [
        ghosttyConfigured
        google-chrome
        discordConfigured
        heroic
        inkscape
        okular
      ];
    };
  in {
    apps.${system}.opencode = {
      type = "app";
      program = "${opencodeConfigured}/bin/opencode";
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

      jedev = pkgs.mkShell {
        buildInputs = with pkgs; [
          nxConfigured
          nodePackages."@angular/cli"
          jdk21
          maven
          spring-boot-cli
          redis
        ];

        shellHook = ''
          export JAVA_HOME=${pkgs.jdk21.home}
          echo "Spring Boot Dev Shell Loaded (JDK 21)"
        '';
      };

      godev = import ./devshells/go.nix {
        inherit pkgs;
        vimFlavor = mvim.packages.${system}.godev;
      };

      nedev = pkgs.mkShell {
        buildInputs = with pkgs; [
          dotnet-sdk_8
          omnisharp-roslyn
          netcoredbg
        ];

        shellHook = ''
          export DOTNET_ROOT=${pkgs.dotnet-sdk_8}
          echo ".NET 8 Dev Shell Loaded"
        '';
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
