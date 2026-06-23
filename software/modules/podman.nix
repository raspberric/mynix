{pkgs, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true; # ← add: app container resolves `db`, `minio`, `valkey-master`
  };
  environment.systemPackages = with pkgs; [
    podman-compose
    docker-compose
  ];
}
