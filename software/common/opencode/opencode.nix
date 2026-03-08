{pkgs, ...}:
pkgs.writeShellApplication {
  name = "opencode";
  runtimeInputs = [pkgs.opencode];
  text = ''
    # Create a writable configuration directory
    CONFIG_DIR="$HOME/.config/opencode"
    mkdir -p "$CONFIG_DIR"

    # Copy the immutable config to the writable location
    # We use -u to update only if the source is newer or size differs,
    # and verify we have write permissions
    cp -u "${./opencode.json}" "$CONFIG_DIR/opencode.json" || true
    chmod 644 "$CONFIG_DIR/opencode.json"

    export OPENCODE_CONFIG_DIR="$CONFIG_DIR"
    exec opencode "$@"
  '';
}

