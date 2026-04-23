{ config, lib, ... }:

let
  cfg = config.services.hermes-agent;
in {
  options.services.hermes-agent = {
    enable = lib.mkEnableOption "Hermes Agent podman container";
    
    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/nousresearch/hermes-agent:latest";
      description = "The container image to use for hermes-agent.";
    };
    
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/hermes-agent";
      description = "Host directory to store hermes-agent data and configuration. Make sure this folder is writeable by UID 10000.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 10000 10000 -"
    ];

    virtualisation.oci-containers.containers.hermes-agent = {
      image = cfg.image;
      
      volumes = [
        "${cfg.dataDir}:/opt/data"
      ];
      
      environment = {
        PYTHONUNBUFFERED = "1";
        # Set npm global prefix to a writable path in the persistent data volume
        NPM_CONFIG_PREFIX = "/opt/data/.npm-global";
        # Add the npm global bin path to PATH
        PATH = "/opt/data/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
      };
      
      # We override the entrypoint to dynamically install claude-code into the persistent 
      # volume before starting the main hermes process.
      entrypoint = "/bin/sh";
      cmd = [
        "-c"
        ''
          mkdir -p /opt/data/.npm-global
          if ! command -v claude >/dev/null; then
            echo "Installing claude-code locally via npm..."
            npm install -g @anthropic-ai/claude-code
          fi
          
          echo "Starting hermes-agent..."
          exec /opt/hermes/docker/entrypoint.sh "$@"
        ''
      ];
    };
  };
}
