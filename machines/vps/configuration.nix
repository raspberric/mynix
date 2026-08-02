{
  lib,
  vpsInstance,
  ...
}: let
  authorizedKeys = import ./authorized-keys.nix;
in {
  assertions = [
    {
      assertion = vpsInstance.deploymentReady;
      message = "Set deploymentReady = true in machines/vps/instance.nix after verifying every generated value.";
    }
    {
      assertion = authorizedKeys != [];
      message = "Add at least one SSH public key to machines/vps/authorized-keys.nix.";
    }
    {
      assertion = !lib.hasInfix "REPLACE_WITH" vpsInstance.disk;
      message = "Replace placeholder VPS disk path with a value verified on the target.";
    }
    {
      assertion = lib.hasPrefix "/dev/disk/by-id/" vpsInstance.disk;
      message = "Use a stable /dev/disk/by-id path for the Contabo VPS disk.";
    }
    {
      assertion = builtins.match ".*-part[0-9]+" vpsInstance.disk == null;
      message = "Use a whole-disk ID, not a /dev/disk/by-id/*-partN partition path.";
    }
    {
      assertion = vpsInstance.interface != "replace-me";
      message = "Replace placeholder VPS network interface with a value verified on the target.";
    }
  ];

  system.stateVersion = "26.05";

  boot.tmp.cleanOnBoot = true;

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["xpo"];
      min-free = 1073741824;
      max-free = 5368709120;
    };
  };

  networking = {
    hostName = "xpo-vps";
    enableIPv6 = false;
    firewall = {
      enable = true;
      allowPing = true;
      allowedUDPPorts = [41641];
    };
  };

  users.mutableUsers = false;
  users.users.xpo = {
    isNormalUser = true;
    description = "Xpo user for vps";
    extraGroups = ["wheel"];
    hashedPasswordFile = "/etc/nixos/secrets/xpo-password-hash";
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  users.users.root.hashedPassword = "!";
  security.sudo.wheelNeedsPassword = true;

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitEmptyPasswords = false;
        AllowAgentForwarding = false;
        X11Forwarding = false;
        MaxAuthTries = 3;
        LoginGraceTime = 30;
      };
    };

    fail2ban.enable = true;
    fstrim.enable = true;
    journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=512M
      RuntimeMaxUse=128M
      MaxRetentionSec=1month
    '';
  };

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  zramSwap.enable = true;
}
