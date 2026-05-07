{...}: {
  users.groups.kosmoy.gid = 10000;
  users.users.xpo.extraGroups = ["kosmoy"];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  virtualisation.oci-containers.backend = "podman";

  systemd.tmpfiles.rules = [
    "d /opt/kosmoy-workspace 2775 10000 10000 -"
  ];

  virtualisation.oci-containers.containers.hermes-agent = {
    image = "docker.io/nousresearch/hermes-agent:latest";
    ports = ["8080:8080"];
    pull = "never";

    volumes = [
      "/opt/hermes-workspace:/opt/data"
      "/home/xpo/Projects/kosmoy:/opt/kosmoy"
    ];

    environment = {
      PYTHONUNBUFFERED = "1";
      HERMES_UID = "10000";
      HERMES_GID = "10000";
      HOME = "/opt/data/home";
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
}
