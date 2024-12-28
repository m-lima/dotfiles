path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    device = lib.mkOption {
      type = lib.types.str;
      description = "Device to use";
      example = "/dev/vda";
    };
    legacy = lib.mkEnableOption "Use BIOS instead of UEFI";
    luks = lib.mkEnableOption "LUKS encryption";
    swap = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
      description = "Size of the swap partition";
      example = "8G";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices =
      let
        btrfs = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "@" = {
              mountpoint = "/";
              mountOptions = [
                "noatime"
                "compress=zstd:3"
              ];
            };
            "@nix" = {
              mountpoint = "/nix";
              mountOptions = [
                "noatime"
                "compress=zstd:3"
              ];
            };
            "@persist" = {
              mountpoint = "/persist";
              mountOptions = [
                "noatime"
                "compress=zstd:3"
              ];
            };
            "@log" = {
              mountpoint = "/var/log";
              mountOptions = [
                "noatime"
                "compress=zstd:3"
              ];
            };
            "@snapshots" = {
              mountpoint = "/.btrfs/snapshots";
              mountOptions = [
                "noatime"
                "compress=zstd:3"
              ];
            };
          };
          mountpoint = "/.btrfs/volume";
          mountOptions = [
            "noatime"
            "compress=zstd:3"
          ];
        };
      in
      {
        disk = {
          main = {
            type = "disk";
            device = cfg.device;
            content = {
              type = "gpt";
              partitions = {
                legacy = lib.mkIf cfg.legacy {
                  priority = 0;
                  size = "1M";
                  name = "legacy";
                  type = "EF02";
                };
                boot = {
                  priority = 1;
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
                swap = lib.mkIf (!isNull cfg.swap) {
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
                  content =
                    if cfg.luks then
                      {
                        type = "luks";
                        name = "luks";
                        askPassword = true;
                        settings.allowDiscards = true;
                        content = btrfs;
                      }
                    else
                      btrfs;
                };
              };
            };
          };
        };
      };
  };
}
