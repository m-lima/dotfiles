{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              start = "512M";
              end = "-8G";
              content = {
                type = "luks2";
                name = "luks";
                askPassword = true;
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  type = "crypt";
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
            swap = {
              start = "-8G";
              end = "100%";
              content = {
                type = "swap";
                name = "swap";
                randomEncryption = true;
              };
            };
            boot = {
              start = "0";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                name = "boot";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
          };
        };
      };
    };
  };
}
