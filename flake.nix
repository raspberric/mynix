{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    mvim.url = "path:./mvim";
    nixgl.url = "github:nix-community/nixGL";
  };
  outputs = {
    self,
    nixpkgs,
    mvim,
    nixgl,
  }: let
    system = "x86_64-linux";
    wrapWithNixGL = final: prev: {
      alacritty = final.writeShellScriptBin "alacritty" ''
        exec ${nixgl.packages.x86_64-linux.nixGLDefault}/bin/nixGL ${prev.alacritty}/bin/alacritty "$@"
      '';
    };
    pkgs = import nixpkgs {
      inherit system;
      overlays = [wrapWithNixGL];
    };
  in {
    packages.${system}.default = pkgs.symlinkJoin {
      name = "mySystem";
      paths = with pkgs; [
        tldr
        tmux
        lazygit
        mvim.packages.${system}.default
        nixgl
        alacritty
        nodejs_24
      ];
    };
  };
}
