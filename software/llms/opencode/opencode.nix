{
  pkgs,
  name ? "opencode",
  profile ? name,
  ...
}:
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = [pkgs.opencode];
  text = ''
    # Create a writable configuration directory
    CONFIG_DIR="$HOME/.config/${profile}"
    mkdir -p "$CONFIG_DIR/skills" "$CONFIG_DIR/plugin"

    # Copy the immutable config to the writable location
    # We use -f to force overwrite so the Nix config is strictly declarative
    cp -f "${./opencode.json}" "$CONFIG_DIR/opencode.json" || true
    chmod 644 "$CONFIG_DIR/opencode.json"

    cp -f "${./system-prompt.md}" "$CONFIG_DIR/system-prompt.md" || true
    chmod 644 "$CONFIG_DIR/system-prompt.md"

    # Copy skills
    cp -rf "${./skills}/"* "$CONFIG_DIR/skills/" || true
    chmod -R u=rwX,go=rX "$CONFIG_DIR/skills/"* || true

    # Copy local plugins
    cp -f "${./plugin/agent-memory.ts}" "$CONFIG_DIR/plugin/agent-memory.ts" || true
    chmod 644 "$CONFIG_DIR/plugin/agent-memory.ts"

    # This repo is system config, not an opencode project config. Avoid creating
    # or loading $HOME/config/.opencode when opencode is launched from here.
    CONFIG_REPO="$HOME/config"
    PWD_PHYSICAL="$(pwd -P)"
    if [ -f "$CONFIG_REPO/software/llms/opencode/opencode.nix" ] && { [ "$PWD_PHYSICAL" = "$CONFIG_REPO" ] || [ "''${PWD_PHYSICAL#"$CONFIG_REPO/"}" != "$PWD_PHYSICAL" ]; }; then
      export OPENCODE_DISABLE_PROJECT_CONFIG=1
    fi

    export OPENCODE_CONFIG_DIR="$CONFIG_DIR"
    # Keep OAuth credentials and sessions separate for each subscription.
    export XDG_DATA_HOME="$HOME/.local/share/${profile}"

    exec opencode "$@"
  '';
}
