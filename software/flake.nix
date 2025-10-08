{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nixgl.url = "github:nix-community/nixGL";
    mvim.url = "path:./mvim";
    myTmux = {
      url = "path:./tmux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    # nixgl,
    mvim,
    myTmux,
  }: let
    system = "x86_64-linux";
    # wrapWithNixGL = final: prev: {
    #   alacritty = final.writeShellScriptBin "alacritty" ''
    #     exec ${nixgl.packages.x86_64-linux.nixGLDefault}/bin/nixGL ${prev.alacritty}/bin/alacritty "$@"
    #   '';
    # };
    pkgs = import nixpkgs {
      inherit system;
      # overlays = [wrapWithNixGL];
    };
  in {
    packages.${system}.default = pkgs.symlinkJoin {
      name = "mySystem";
      paths = with pkgs; [
        tldr
        myTmux.packages.${system}.default
        lazygit
        mvim.packages.${system}.default
        # nixgl
        # alacritty
        nodejs_24
        pnpm
        xclip
      ];
    };
  };
}
