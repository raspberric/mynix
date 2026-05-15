{
  config,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Belgrade";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  users.users.xpo = {
    isNormalUser = true;
    description = "xpo";
    extraGroups = ["networkmanager" "wheel"];
  };
  environment.variables.EDITOR = "nvim";
  nixpkgs.config.allowUnfree = true;
  specialisation = {
    on-the-go.configuration = {
      system.nixos.tags = ["on-the-go"];
      boot.blacklistedKernelModules = pkgs.lib.mkForce [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
      ];
      services.xserver.videoDrivers = pkgs.lib.mkForce [
        "modesetting"
      ];
      services.udev.extraRules = pkgs.lib.mkForce ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{remove}="1", ATTR{power/control}="auto"
      '';
    };
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "no";
    openFirewall = true;
  };

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];
  networking.firewall.checkReversePath = "loose";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.pcscd = {
    enable = true;
    plugins = [pkgs.ccid];
  };

  system.stateVersion = "25.05";
}
