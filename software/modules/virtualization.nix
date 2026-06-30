{
  pkgs,
  unstable,
  ...
}: {
  virtualisation.docker = {
    package = unstable.docker_29;
    enable = true;
    enableOnBoot = false;
    rootless = {
      package = unstable.docker_29;
      enable = true;
      setSocketVariable = true;
    };
  };
  # keep systemctl services alive on logout
  users.users.xpo.linger = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    dockerSocket.enable = false;
  };
  environment.systemPackages = with pkgs; [
    podman-compose
    unstable.docker-compose
    unstable.docker-buildx
    lazydocker
  ];
}
