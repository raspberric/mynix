{pkgs, ...}: let
  opencodeConfigured = import ./common/opencode/opencode.nix {inherit pkgs;};
  claudeConfigured = import ./common/claude-code/claude-code.nix {inherit pkgs;};
in
  pkgs.symlinkJoin {
    name = "dev";
    paths = with pkgs; [
      nodejs_24
      pnpm
      opencodeConfigured
      claudeConfigured
    ];
  }
