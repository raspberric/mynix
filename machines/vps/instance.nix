{
  # Replace every placeholder using values observed in Contabo rescue mode.
  deploymentReady = false;
  disk = "/dev/disk/by-id/REPLACE_WITH_CONTABO_DISK";
  bootMode = "REPLACE_WITH_bios_OR_uefi";
  interface = "replace-me";

  ipv4 = {
    address = "192.0.2.1";
    prefixLength = 32;
    gateway = "192.0.2.254";
  };

  sshKeys = [];
}
