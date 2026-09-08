{
  pkgs,
  claudeMemoryLimits ? null,
  ...
}: let
  claudeConfigured = import ./llms/claude-code/claude-code.nix {inherit pkgs claudeMemoryLimits;};
  opencodeConfigured = import ./llms/opencode/opencode.nix {inherit pkgs;};
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
