{
  pkgs,
  herdr,
  ...
}: let
  configFile = ./herdr-config.toml;
in
  pkgs.writeShellApplication {
    name = "herdr";
    runtimeInputs = [herdr];
    text = ''
      export HERDR_CONFIG_PATH=${configFile}
      exec ${herdr}/bin/herdr "$@"
    '';
    meta = herdr.meta;
  }
