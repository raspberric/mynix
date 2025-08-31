{
  description = "";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    mvim.url = "path:./mvim";
  };
  outputs = {self, nixpkgs, mvim}: 
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages.${system}.default = pkgs.symlinkJoin {
        name = "mySystem";
        paths = with pkgs; [
	  tldr
	  tmux
	  lazygit
	  mvim.packages.${system}.default
	];

      };
    };
}
