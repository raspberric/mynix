{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.useDHCP = lib.mkDefault true;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = lib.mkForce ["/dev/sda"];
  };
  boot.loader.efi.canTouchEfiVariables = false;
}
