{
  pkgs,
  ...
}:
pkgs.writeShellApplication {
  name = "opencode";
  runtimeInputs = [pkgs.opencode];
  text = ''
      # Create a writable configuration directory
      CONFIG_DIR="$HOME/.config/opencode"
      mkdir -p "$CONFIG_DIR/skills" "$CONFIG_DIR/plugin"

      # Copy the immutable config to the writable location
      # We use -f to force overwrite so the Nix config is strictly declarative
      cp -f "${./opencode.json}" "$CONFIG_DIR/opencode.json" || true
      chmod 644 "$CONFIG_DIR/opencode.json"

      # Copy skills
      cp -rf "${./skills}/"* "$CONFIG_DIR/skills/" || true
      install -Dm644 "${../../modules/free-llm-discovery/SKILL.md}" "$CONFIG_DIR/skills/free-llm-discovery/SKILL.md"
      chmod -R u=rwX,go=rX "$CONFIG_DIR/skills/"* || true

      # Copy local plugins
      cp -f "${./plugin/agent-memory.ts}" "$CONFIG_DIR/plugin/agent-memory.ts" || true
      chmod 644 "$CONFIG_DIR/plugin/agent-memory.ts"

      # This repo is system config, not an opencode project config. Avoid creating
      # or loading $HOME/config/.opencode when opencode is launched from here.
      CONFIG_REPO="$HOME/config"
      PWD_PHYSICAL="$(pwd -P)"
      if [ -f "$CONFIG_REPO/software/common/opencode/opencode.nix" ] && { [ "$PWD_PHYSICAL" = "$CONFIG_REPO" ] || [ "''${PWD_PHYSICAL#"$CONFIG_REPO/"}" != "$PWD_PHYSICAL" ]; }; then
        export OPENCODE_DISABLE_PROJECT_CONFIG=1
      fi

      export OPENCODE_CONFIG_DIR="$CONFIG_DIR"

      exec opencode "$@"
  '';
}
