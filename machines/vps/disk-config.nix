{vpsInstance, ...}: {
  disko.devices.disk.main = {
    type = "disk";
    device = vpsInstance.disk;
    content = {
      type = "gpt";
      partitions = {
        bios = {
          size = "1M";
          type = "EF02";
          priority = 1;
        };
        ESP = {
          size = "512M";
          type = "EF00";
          priority = 2;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
        root = {
          size = "100%";
          priority = 3;
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = ["noatime"];
            extraArgs = ["-m" "1"];
          };
        };
      };
    };
  };
}
