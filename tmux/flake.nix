{
  description = "Tmux config flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    tmuxConfigPath = ./tmux.conf;
  in {
    packages.${system}.default = pkgs.writeShellApplication {
      name = "tmux";
      runtimeInputs = with pkgs; [
        tmux
        tmuxPlugins.yank
      ];
      text = ''
        exec tmux -f "${tmuxConfigPath}" "$@"
      '';
    };
  };
}
