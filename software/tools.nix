{pkgs, ...}: let
  gitConfigured = import ./common/git.nix {inherit pkgs;};
  lazygitConfigured = import ./common/lazygit.nix {inherit pkgs;};
  tmuxConfigured = import ./common/tmux.nix {inherit pkgs;};
  pkillOnPort = import ./scripts/pkillOnPort.nix {inherit pkgs;};
in {
  apps = pkgs.symlinkJoin {
    name = "Configured Tools";
    paths = with pkgs; [
      tmuxConfigured
      gitConfigured
      lazygitConfigured
      tldr
      xclip
      ripgrep
      pkillOnPort
      mvim.packages.${system}.mvim
      yazi
    ];
  };
}
