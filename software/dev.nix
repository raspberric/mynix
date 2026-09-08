{
  pkgs,
  claudeMemoryLimits ? null,
  ...
}: let
  claudeConfigured = import ./llms/claude-code/claude-code.nix {inherit pkgs claudeMemoryLimits;};
  opencodePersonal = import ./llms/opencode/opencode.nix {
    inherit pkgs;
    name = "opencode-personal";
  };
  opencodeWork = import ./llms/opencode/opencode.nix {
    inherit pkgs;
    name = "opencode-work";
  };
in
  pkgs.symlinkJoin {
    name = "dev";
    paths = with pkgs; [
      nodejs_24
      pnpm
      claudeConfigured
      opencodePersonal
      opencodeWork
      python314
      uv
      gcc
      gnumake
    ];
  }
