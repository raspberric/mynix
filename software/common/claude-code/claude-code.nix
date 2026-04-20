{pkgs, ...}:
pkgs.writeShellApplication {
  name = "claude";
  runtimeInputs = [pkgs.claude-code];
  text = ''
    # Create the config directory if it doesn't exist
    CONFIG_DIR="$HOME/.claude"
    mkdir -p "$CONFIG_DIR/skills/caveman"

    # Copy the skill into the Claude-Code skills directory 
    # so Claude can dynamically load and use it via /caveman
    cp -f "${./caveman.md}" "$CONFIG_DIR/skills/caveman/SKILL.md"

    exec claude "$@"
  '';
}