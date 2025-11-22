{
  description = "Lazygit config flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    lazygitConfigPath = ./lazygit.yml;
  in {
    packages.${system}.default = pkgs.writeShellApplication {
      name = "lazygit";
      runtimeInputs = with pkgs; [
        lazygit
      ];
      text = ''
        exec lazygit -ucf "${lazygitConfigPath}" "$@"
      '';
    };
  };
}
