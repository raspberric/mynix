{pkgs, ...}: let
  claudeConfigured = import ./common/claude-code/claude-code.nix {inherit pkgs;};
  opencodeConfigured = import ./common/opencode/opencode.nix {inherit pkgs;};
in
  pkgs.symlinkJoin {
    name = "dev";
    paths = with pkgs; [
      nodejs_24
      pnpm
      claudeConfigured
      opencodeConfigured
      python314
      uv
      gcc
      gnumake
    ];
  }
