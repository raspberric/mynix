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
          ];
      };
    };
    gitConfigured = import ./common/git.nix {inherit pkgs;};
    lazygitConfigured = import ./common/lazygit.nix {inherit pkgs;};
    tmuxConfigured = import ./common/tmux.nix {inherit pkgs;};
    ghosttyConfigured = import ./gui/ghostty.nix {inherit pkgs;};

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
        mvim.packages.${system}.default
        mvim.packages.${system}.fedev
        openCodeSrc.packages.${system}.default
      ];
    };

    guiApps = pkgs.symlinkJoin {
      name = "gui apps";
      paths = with pkgs; [
        ghosttyConfigured
        google-chrome
        (discord.override {
          withOpenASAR = true;
          withVencord = true;
        })
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
      default = pkgs.mkShell {
        buildInputs = [standardApps];
        shellHook = ''
          echo "Welcome to the rice fields MF!"
        '';
      };
    };
  };
}
