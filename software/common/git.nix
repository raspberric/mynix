{pkgs}: let
  configFile = builtins.toFile "gitconfig-custom" ''
    [user]
      name = "Raspberric"
      email = "nikolamalinovic42@gmail.com"
    [core]
      editor = nvim
    [merge]
      ff = false
  '';
in
  pkgs.writeShellApplication {
    name = "git";
    runtimeInputs = [
      pkgs.git
    ];
    text = ''
      export GIT_CONFIG_GLOBAL="${configFile}"
      exec ${pkgs.git}/bin/git "$@"
    '';
    meta = pkgs.git.meta;
  }
