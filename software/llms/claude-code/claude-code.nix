{
  pkgs,
  claudeMemoryLimits ? null,
  ...
}: let
  launchClaude =
    if claudeMemoryLimits == null
    then ''exec claude "$@"''
    else ''
      exec systemd-run \
        --user \
        --scope \
        --quiet \
        --collect \
        --same-dir \
        --property=MemoryHigh=${claudeMemoryLimits.high} \
        --property=MemoryMax=${claudeMemoryLimits.max} \
        --property=MemorySwapMax=${claudeMemoryLimits.swapMax} \
        claude "$@"
    '';
in
pkgs.writeShellApplication {
  name = "claude";
  runtimeInputs = [pkgs.claude-code] ++ pkgs.lib.optional (claudeMemoryLimits != null) pkgs.systemd;
  text = ''
    # Create the config directory if it doesn't exist
    CONFIG_DIR="$HOME/.claude"
    mkdir -p "$CONFIG_DIR/skills/caveman"

    # Copy the skill into the Claude-Code skills directory 
    # so Claude can dynamically load and use it via /caveman
    cp -f "${./caveman.md}" "$CONFIG_DIR/skills/caveman/SKILL.md"

    ${launchClaude}
  '';
}
