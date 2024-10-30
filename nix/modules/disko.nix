{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.disko;
in {
  options = {
    modules.disko = {
      # TODO: Go over every config
      luks = lib.mkEnableOption "LUKS encryption";
      swap = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
        description = "Size of the swap partition";
        example = "8G";
      };
    };
  };

  config = {
    disko.devices =
      let
        btrfs = {
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
      in {
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
                swap = lib.mkIf (! isNull cfg.swap) {
                  size = cfg.swap;
                  name = "swap";
                  content = {
                    type = "swap";
                    randomEncryption = cfg.luks;
                  };
                };
                main = {
                  size = "100%";
                  name = "main";
                  content = if cfg.luks
                    then {
                      type = "luks";
                      name = "luks";
                      askPassword = true;
                      settings.allowDiscards = true;
                      content = btrfs;
                    } else btrfs;
                };
              };
            };
          };
        };
      };
  };
}
