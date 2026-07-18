{pkgs, ...}: {
  system.stateVersion = "25.05";

  wsl.enable = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  networking = {
    hostName = "xpoVps";
    networkmanager.enable = true;
  };

  users.users.xpo = {
    isNormalUser = true;
    description = "Xpo user for wsl";
    extraGroups = ["wheel"];
  };
}
