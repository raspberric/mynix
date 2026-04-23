{
  config,
  lib,
  ...
}: let
  cfg = config.services.hermes-agent;
in {
  options.services.hermes-agent = {
    enable = lib.mkEnableOption "Hermes Agent podman container";

    image = lib.mkOption {
      type = lib.types.str;
      default = "docker.io/nousresearch/hermes-agent:latest";
      description = "The container image to use for hermes-agent.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/opt/hermes-workspace";
      description = "Host directory to store hermes-agent data and configuration. Make sure this folder is writeable by UID 10000.";
    };

    ports = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "8080:8080" ];
      description = "Ports to expose from the container to the host.";
    };

    projectDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional host directory to mount into /opt/project in the container.";
    };

    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "xpo";
      description = "The user on the host that should have access to the hermes workspace.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.hermes.gid = 10000;
    users.users.${cfg.adminUser}.extraGroups = [ "hermes" ];

    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 2775 10000 10000 -"
    ];

    virtualisation.oci-containers.containers.hermes-agent = {
      image = cfg.image;
      ports = cfg.ports;
      pull = "never";

      volumes = [
        "${cfg.dataDir}:/opt/data"
      ] ++ lib.optional (cfg.projectDir != null) "${cfg.projectDir}:/opt/kosmoy";

      environment = {
        PYTHONUNBUFFERED = "1";
        # By default, npm tries to install global packages to /usr/local/ which requires root.
        # Since this container runs as a non-root user (UID 10000), we redirect global npm 
        # installs to our persistent data volume (/opt/data inside the container, which maps 
        # to our dataDir on the host).
        NPM_CONFIG_PREFIX = "/opt/data/.npm-global";
        # Add our custom npm global bin path and the container's python venv to PATH
        PATH = "/opt/data/.npm-global/bin:/opt/hermes/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
      };

      # We override the entrypoint to dynamically install claude-code into the persistent 
      # volume before starting the main hermes process.
      # Note: /opt/hermes/docker/entrypoint.sh is the hardcoded path INSIDE the provided 
      # docker.io container image where the NousResearch developers put their startup script.
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
        "--"
        "gateway"
        "run"
      ];
    };
  };
}
