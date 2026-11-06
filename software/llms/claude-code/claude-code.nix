{
  pkgs,
  claudeMemoryLimits ? null,
  ...
}: let
  # Pinned to Anthropic's stable channel; checksum from the release manifest.
  claudeCode = pkgs.claude-code.overrideAttrs (finalAttrs: _prev: {
    version = "2.1.311";
    src = pkgs.fetchurl {
      url = "https://downloads.claude.ai/claude-code-releases/${finalAttrs.version}/linux-x64/claude";
      hash = "sha256-htwfzGlJgVnq8V9EZhPoRwEPkDa/u9/9TEk1C+hImto=";
    };
  });
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
  runtimeInputs = [claudeCode] ++ pkgs.lib.optional (claudeMemoryLimits != null) pkgs.systemd;
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
