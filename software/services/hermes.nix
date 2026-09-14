{
  config,
  pkgs,
  ...
}: {
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;

    environment.HERMES_DOCKER_BINARY = "${pkgs.podman}/bin/podman";

    settings = {
      model = {
        provider = "custom";
        default = "free-coding";
        base_url = "http://127.0.0.1:4000/v1";
        # LiteLLM is localhost-only and does not require client authentication.
        api_key = "local";
      };

      terminal = {
        # Hermes calls Podman through its Docker-compatible terminal backend.
        backend = "docker";
        cwd = "/workspace";
        docker_image = "docker.io/nikolaik/python-nodejs:python3.11-nodejs20";
        docker_mount_cwd_to_workspace = false;
        docker_network = true;
        container_cpu = 1;
        container_memory = 1024;
        container_persistent = false;
        lifetime_seconds = 300;
      };

      security.allow_lazy_installs = false;
    };
  };

  # Hermes needs a subordinate ID range and a delegated cgroup subtree to
  # create rootless, resource-limited Podman sandboxes from its system unit.
  users.users.hermes.autoSubUidGidRange = true;
  users.users.xpo.extraGroups = ["hermes"];

  systemd.services.hermes-agent = {
    after = ["litellm.service" "network-online.target"];
    requires = ["litellm.service"];
    wants = ["network-online.target"];

    environment.XDG_RUNTIME_DIR = "/run/hermes-agent";
    serviceConfig = {
      RuntimeDirectory = "hermes-agent";
      RuntimeDirectoryMode = "0700";
      Delegate = "cpu cpuset io memory pids";
    };
  };

  assertions = [
    {
      assertion = config.services.litellm.host == "127.0.0.1";
      message = "Hermes must use a localhost-only LiteLLM gateway.";
    }
    {
      assertion = !config.services.litellm.openFirewall;
      message = "Hermes's LiteLLM gateway must not be exposed through the firewall.";
    }
  ];
}
