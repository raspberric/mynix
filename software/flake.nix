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
            "claude-code"
          ];
      };
    };
    gitConfigured = import ./common/git.nix {inherit pkgs;};
    lazygitConfigured = import ./common/lazygit.nix {inherit pkgs;};
    tmuxConfigured = import ./common/tmux.nix {inherit pkgs;};
    ghosttyConfigured = import ./gui/ghostty.nix {inherit pkgs;};
    discordConfigured = import ./gui/discord.nix {inherit pkgs;};
    opencodeConfigured = import ./common/opencode/opencode.nix {inherit pkgs;};
    pkillOnPort = import ./scripts/pkillOnPort.nix {inherit pkgs;};
    okular = import ./gui/okular.nix {inherit pkgs;};
    srbIdPkcs11Chrome = import ./common/srb-id-pkcs11-chrome.nix {inherit pkgs;};
    claudeConfigured = import ./common/claude-code/claude-code.nix {inherit pkgs;};

    standardApps = pkgs.symlinkJoin {
      name = "standard apps";
      paths = with pkgs; [
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
        srbIdPkcs11Chrome
        mvim.packages.${system}.mvim
        mvim.packages.${system}.fedev
        claudeConfigured
      ];
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
    nixosModules = {
      hermes-agent = import ./services/hermes.nix;
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
