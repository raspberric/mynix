{
  pkgs,
  unstable,
  ...
}: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    rootless = {
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
  environment.sessionVariables.BUILDX_BAKE_FILE_RELATIVE_PATHS = "1";
}
