{pkgs, ...}: let
  gitConfigured = import ./common/git.nix {inherit pkgs;};
  lazygitConfigured = import ./common/lazygit.nix {inherit pkgs;};
  tmuxConfigured = import ./common/tmux.nix {inherit pkgs;};
  pkillOnPort = import ./scripts/pkillOnPort.nix {inherit pkgs;};
  tuxedo = import ./common/tuxedo.nix {inherit pkgs;};
in
  pkgs.symlinkJoin {
    name = "tools";
    paths = with pkgs; [
      tmuxConfigured
      gitConfigured
      lazygitConfigured
      tldr
      xclip
      ripgrep
      pkillOnPort
      yazi
      tuxedo
      nh
    ];
  }
