{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              name = "boot";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "1G";
              name = "swap";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            main = {
              size = "100%";
              name = "main";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "noatime" "compress=zstd:3" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "noatime" "compress=zstd:3" ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "noatime" "compress=zstd:3" ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "noatime" "compress=zstd:3" ];
                  };
                  "@snapshots" = {
                    mountpoint = "/.btrfs/snapshots";
                    mountOptions = [ "noatime" "compress=zstd:3" ];
                  };
                };
                mountpoint = "/.btrfs/volume";
                mountOptions = [ "noatime" "compress=zstd:3" ];
              };
            };
          };
        };
      };
    };
  };
}
