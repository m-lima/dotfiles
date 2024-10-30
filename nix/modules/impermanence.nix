{
  userName,
  lib,
  config,
  util,
  ...
}:
let
  cfg = config.modules.impermanence;
in {
  options = {
    modules.impermanence = {
      enable = util.mkDisableOption "impermanence";
      wipe = {
        enable = util.mkDisableOption "disk wiping";
        device = lib.mkOption {
          description = "The device to wipe on reboot";
          example = "/dev/mapper/btrfs";
          default = config.fileSystems."/.btrfs/volume".device;
          type = types.str;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.postDeviceCommands = mkIf cfg.wipe.enable mkAfter ''
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
    '';

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
        "/etc/nixos/flake.nix"
      ] ++ (
        if config.modules.base.services.ssh.enable then [
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ] else []
      );

      users."${userName}" = {
        directories = [
          "code"
          ".local/share/zoxide"
        ];
        files = [
          ".zsh_history"
        ];
      };
    };
  };
}
