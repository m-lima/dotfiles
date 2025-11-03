path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  celo = config.celo.modules;
  user = celo.core.user;
  cfgDisko = celo.core.disko;
in
{
  options = util.mkOptions path {
    wipe = {
      enable = lib.mkEnableOption "disk wiping";
      device = lib.mkOption {
        description = "The device to wipe on reboot";
        example = "/dev/mapper/btrfs";
        default = config.fileSystems."/.btrfs/volume".device;
        type = lib.types.str;
      };
      retainRoot = lib.mkOption {
        description = "Days to retain of old roots";
        type = lib.types.ints.u16;
        default = if cfg.wipe.enable && !celo.services.snapper.enable then 30 else 0;
      };
    };
    retain = {
      system = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.singleLineStr;
          description = "Directories to keep permanent";
          default = [ ];
        };
        files = lib.mkOption {
          type = lib.types.listOf lib.types.singleLineStr;
          description = "Files to keep permanent";
          default = [ ];
        };
      };
      user = {
        directories = lib.mkOption {
          type = lib.types.listOf lib.types.singleLineStr;
          description = "Directories to keep permanent";
          default = [
            "code"
            "bin"
          ];
        };
        files = lib.mkOption {
          type = lib.types.listOf lib.types.singleLineStr;
          description = "Files to keep permanent";
          default = [ ];
          example = [ ".gnupg/pubring.kbx" ];
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    celo.modules = {
      core.disko.extraMounts = {
        persist = {
          name = "@persist";
          mountpoint = "/persist";
        };
      };

      services.snapper.mounts = lib.mkAfter [ "persist" ];
    };

    boot.initrd.postDeviceCommands = lib.mkIf cfg.wipe.enable (
      lib.mkAfter (
        ''
          mkdir /btrfs
          mount -o noatime,compress=zstd:3 ${cfg.wipe.device} /btrfs

          delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                  delete_subvolume_recursively "/btrfs/$i"
              done
              btrfs subvolume delete "$1"
          }
        ''
        + (
          if cfg.wipe.retainRoot > 0 then
            ''
              if [[ -e /btrfs/${cfgDisko.mounts.root.name} ]]; then
                  mkdir -p /btrfs/old
                  timestamp=$(date --date="@$(stat -c %Y /btrfs/@)" "+%Y-%m-%d_%H:%M:%S")
                  mv /btrfs/${cfgDisko.mounts.root.name} "/btrfs/old/$timestamp"
              fi

              for i in $(find /btrfs/old/ -maxdepth 1 -mtime +${toString cfg.wipe.retainRoot}); do
                  delete_subvolume_recursively "$i"
              done
            ''
          else
            ''
              delete_subvolume_recursively /btrfs/${cfgDisko.mounts.root.name}
            ''
        )
        + ''
          btrfs subvolume create /btrfs/${cfgDisko.mounts.root.name}
          umount /btrfs
        ''
      )
    );

    # Make persistent fileSystems available at boot
    fileSystems = {
      ${cfgDisko.mounts.persist.mountpoint}.neededForBoot = true;
      ${cfgDisko.mounts.log.mountpoint}.neededForBoot = true;
    };

    environment.persistence.${cfgDisko.mounts.persist.mountpoint} = {
      directories = [
        "/etc/nixos"
        "/var/lib/nixos"
      ]
      ++ cfg.retain.system.directories;

      files = [ "/etc/machine-id" ] ++ cfg.retain.system.files;

      users = lib.mkIf user.enable {
        ${user.userName} = {
          directories = cfg.retain.user.directories;
          files = cfg.retain.user.files;
        };
      };
    };
  };
}
