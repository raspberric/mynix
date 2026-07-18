{pkgs, ...}: let
  # 1. Dynamically target the key directly inside your local ~/.ssh directory
  homeDir = builtins.getEnv "HOME";
  keyPath = /. + "${homeDir}/.ssh/id_rsa.pub";

  # 2. Check if the file exists on your local machine (ignores Git status)
  keyExists = builtins.pathExists keyPath;
in
  assert pkgs.lib.assertMsg keyExists ''
    [ERROR] Could not find your local SSH public key at: ${toString keyPath}
    Please ensure the file exists on your local machine before running the build.
  ''; {
    system.stateVersion = "25.05";

    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };
    };

    networking = {
      hostName = "xpoVps";
      networkmanager.enable = true;
    };

    users.users.xpo = {
      isNormalUser = true;
      description = "Xpo user for vps";
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3Nza... your-key-here"
      ];
    };

    services = {
      qemuGuest.enable = true;

      openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      fail2ban.enable = true;
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443]; # SSH, HTTP, HTTPS
    };
  }
