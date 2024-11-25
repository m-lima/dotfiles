path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  user = config.celo.modules.core.user;
in {
  options = util.mkOptions path {
    wipe = {
      enable = lib.mkEnableOption "disk wiping";
      device = lib.mkOption {
        description = "The device to wipe on reboot";
        example = "/dev/mapper/btrfs";
        default = config.fileSystems."/.btrfs/volume".device;
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.postDeviceCommands = lib.mkIf cfg.wipe.enable (lib.mkAfter ''
      mkdir /btrfs
      mount -o noatime,compress=zstd:3 ${cfg.wipe.device} /btrfs
      if [[ -e /btrfs/@ ]]; then
          mkdir -p /btrfs/old
          timestamp=$(date --date="@$(stat -c %Y /btrfs/@)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs/@ "/btrfs/old/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs/old/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs/@
      umount /btrfs
    '');

    # Make persistent fileSystems available at boot
    fileSystems = {
      "/persist".neededForBoot = true;
      "/var/log".neededForBoot = true;
    };

    environment.persistence."/persist" = {
      directories = [
        "/etc/nixos"
        "/var/lib/nixos"
      ];

      files = [
        "/etc/machine-id"
      ]
      ++ (
        if config.celo.modules.services.ssh.enable then [
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ] else []
      );

      users = lib.mkIf user.enable {
        ${user.userName} = {
          directories = [
            "code"
            ".local/share/zoxide"
          ];
          files = [
            ".ssh/id_rsa"
            ".ssh/id_rsa.pub"
            ".ssh/id_ed25519"
            ".ssh/id_ed25519.pub"
            ".ssh/known_hosts"
            ".zsh_history"
            ".gnupg/pubring.kbx"
          ];
        };
      };
    };
  };
}
