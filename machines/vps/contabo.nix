{
  lib,
  modulesPath,
  vpsInstance,
  ...
}: let
  isEfi = vpsInstance.bootMode == "uefi";
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  assertions = lib.optionals vpsInstance.deploymentReady [
    {
      assertion = builtins.elem vpsInstance.bootMode ["bios" "uefi"];
      message = "Set VPS bootMode to bios or uefi after checking /sys/firmware/efi in Contabo rescue mode.";
    }
    {
      assertion = vpsInstance.ipv4.address != "192.0.2.1";
      message = "Replace documentation-only IPv4 address in machines/vps/instance.nix.";
    }
    {
      assertion = vpsInstance.ipv4.gateway != "192.0.2.254";
      message = "Replace documentation-only IPv4 gateway in machines/vps/instance.nix.";
    }
  ];

  networking = {
    useDHCP = false;
    interfaces.${vpsInstance.interface} = {
      useDHCP = false;
      ipv4.addresses = [
        {
          inherit (vpsInstance.ipv4) address prefixLength;
        }
      ];
    };
    defaultGateway = {
      address = vpsInstance.ipv4.gateway;
      interface = vpsInstance.interface;
    };
    nameservers = ["1.1.1.1" "9.9.9.9"];
  };

  boot.loader = {
    efi.canTouchEfiVariables = false;
    grub = {
      enable = true;
      configurationLimit = 10;
      devices = lib.mkForce (
        if isEfi
        then ["nodev"]
        else [vpsInstance.disk]
      );
      efiSupport = isEfi;
      efiInstallAsRemovable = isEfi;
    };
  };
}
