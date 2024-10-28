{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.impermanence;
in {
  options.modules.impermanence = {
    enable = mkOption {
      default = true;
      description = ''
        Enable impermanence.
      '';
      type = types.bool;
    };

    device = mkOption {
      description = "The device to wipe on reboot";
      example = "/dev/mapper/btrfs";
      default = config.fileSystems."/.btrfs/volume".device;
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.postDeviceCommands = mkAfter ''
      mkdir /btrfs
      mount -o noatime,compress=zstd:3 ${cfg.device} /btrfs
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
        if config.modules.ssh.enable then [
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ] else []
      );
    };
  };
}
