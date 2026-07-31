{
  pkgs,
  desktopTools ? true,
  ...
}: let
  gitConfigured = import ./common/git.nix {inherit pkgs;};
  lazygitConfigured = import ./common/lazygit.nix {inherit pkgs;};
  tmuxConfigured = import ./common/tmux.nix {inherit pkgs;};
  pkillOnPort = import ./scripts/pkillOnPort.nix {inherit pkgs;};
  tuxedo = import ./common/tuxedo.nix {inherit pkgs;};
in
  pkgs.symlinkJoin {
    name = "tools";
    paths =
      (with pkgs; [
        tmuxConfigured
        gitConfigured
        lazygitConfigured
        tldr
        ripgrep
        pkillOnPort
        yazi
        nh
        jq
        unar
      ])
      ++ pkgs.lib.optionals desktopTools (with pkgs; [
        xclip
        tuxedo
      ]);
  }
