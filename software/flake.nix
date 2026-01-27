{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    mvim = {
      url = "path:./common/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openCodeSrc = {
      url = "github:sst/opencode";
    };
  };
  outputs = {
    self,
    nixpkgs,
    mvim,
    openCodeSrc,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
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
          ];
      };
    };
    gitConfigured = import ./common/git.nix {inherit pkgs;};
    lazygitConfigured = import ./common/lazygit.nix {inherit pkgs;};
    tmuxConfigured = import ./common/tmux.nix {inherit pkgs;};
    ghosttyConfigured = import ./gui/ghostty.nix {inherit pkgs;};
    discordConfigured = import ./gui/discord.nix {inherit pkgs;};
    nxConfigured = import ./common/nx/default.nix {inherit pkgs;};

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
          openCodeSrc.packages.${system}.default
          posting
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
      ];
    };
  in {
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
