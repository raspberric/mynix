{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    mvim = {
      url = "path:./mvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    myTmux = {
      url = "path:./tmux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazygit = {
      url = "path:./lazygit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "path:./ghostty";
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
    myTmux,
    lazygit,
    ghostty,
    openCodeSrc,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ghostty.overlays.default];
    };
  in {
    packages.${system}.default = pkgs.symlinkJoin {
      name = "mySystem";
      paths = with pkgs; [
        tldr
        myTmux.packages.${system}.default
        lazygit.packages.${system}.default
        mvim.packages.${system}.default
        ghosttyDesktopItem
        nodejs_24
        pnpm
        xclip
        ripgrep
        openCodeSrc.packages.${system}.default
      ];
    };
  };
}
