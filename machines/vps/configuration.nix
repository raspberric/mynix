{...}: {
  system.stateVersion = "25.11";

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
  };

  networking = {
    hostName = "xpo-vps";
    firewall.enable = true;
  };

  users.users.xpo = {
    isNormalUser = true;
    description = "Xpo user for vps";
    extraGroups = ["wheel"];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = [
      # Add your SSH public key before installing the VPS.
    ];
  };

  users.users.root.hashedPassword = "!";
  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    fail2ban.enable = true;
  };

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  zramSwap.enable = true;
}
