{pkgs, ...}: let
  configFile = builtins.toFile "lazygit-config.yml" ''
    git:
        branchLogCmd: "git log --graph --all --color=always --abbrev-commit --decorate --date=relative --pretty=medium {{branchName}} --";
  '';
in
  pkgs.writeShellApplication {
    name = "lazygit";
    runtimeInputs = [
      pkgs.lazygit
    ];
    text = ''
      exec ${pkgs.lazygit}/bin/lazygit -ucf "${configFile}" "$@"
    '';

    meta = pkgs.lazygit.meta;
  }
