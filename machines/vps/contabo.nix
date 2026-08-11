{
  lib,
  modulesPath,
  vpsInstance,
  ...
}: let
  isEfi = vpsInstance.bootMode == "uefi";
  isValidIPv4 = address: let
    octets = lib.splitString "." address;
    isValidOctet = octet:
      builtins.match "0|[1-9][0-9]{0,2}" octet
      != null
      && lib.toInt octet <= 255;
  in
    builtins.length octets == 4 && builtins.all isValidOctet octets;
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  assertions = [
    {
      assertion = builtins.elem vpsInstance.bootMode ["bios" "uefi"];
      message = "Set VPS bootMode to bios or uefi after checking /sys/firmware/efi on the target.";
    }
    {
      assertion = isValidIPv4 vpsInstance.ipv4.address && vpsInstance.ipv4.address != "192.0.2.1";
      message = "Set a valid, non-placeholder IPv4 address in machines/vps/instance.nix.";
    }
    {
      assertion = vpsInstance.ipv4.prefixLength >= 0 && vpsInstance.ipv4.prefixLength <= 32;
      message = "Set VPS IPv4 prefixLength between 0 and 32.";
    }
    {
      assertion = isValidIPv4 vpsInstance.ipv4.gateway && vpsInstance.ipv4.gateway != "192.0.2.254";
      message = "Set a valid, non-placeholder IPv4 gateway in machines/vps/instance.nix.";
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
