{pkgs, ...}: let
  config = ./config;
in
  pkgs.writeShellApplication {
    name = "pi";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      config_dir="$HOME/.config/pi-coding-agent"
      mkdir -p "$config_dir"

      # Replace every declarative resource so removed skills cannot survive an update.
      rm -rf "$config_dir/skills"
      cp -R "${config}/skills" "$config_dir/skills"
      install -m 0644 "${config}/settings.json" "$config_dir/settings.json"
      install -m 0644 "${config}/models.json" "$config_dir/models.json"
      chmod -R u=rwX,go=rX "$config_dir/skills"

      export PI_CODING_AGENT_DIR="$config_dir"
      export PI_SKIP_VERSION_CHECK=1
      export PI_TELEMETRY=0

      exec "${pkgs.pi-coding-agent}/bin/pi" "$@"
    '';
  }
