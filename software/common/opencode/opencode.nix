{pkgs, ...}: let
  opencodeUpdated =
    pkgs.opencode.overrideAttrs
    ({
      version = "1.17.3";
      src = pkgs.fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        rev = "v1.17.3";
        hash = "sha256-9mg/AoX79RvsQS9SIHo/7BhPVbINyR6okQGIP+3e+jU=";
      };
      patches = [];
    }).overrideAttrs {patches = [];};
in
  pkgs.writeShellApplication {
    name = "opencode";
    runtimeInputs = [opencodeUpdated];
    text = ''
      # Create a writable configuration directory
      CONFIG_DIR="$HOME/.config/opencode"
      mkdir -p "$CONFIG_DIR/skills"

      # Copy the immutable config to the writable location
      # We use -f to force overwrite so the Nix config is strictly declarative
      cp -f "${./opencode.json}" "$CONFIG_DIR/opencode.json" || true
      chmod 644 "$CONFIG_DIR/opencode.json"

      # Copy skills
      cp -rf "${./skills}/"* "$CONFIG_DIR/skills/" || true
      chmod -R 644 "$CONFIG_DIR/skills/"* || true

      export OPENCODE_CONFIG_DIR="$CONFIG_DIR"

      exec opencode "$@"
    '';
  }
