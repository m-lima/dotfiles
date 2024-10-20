# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/23e9c9b8-d68a-4a09-9055-f2025919f28f";
      fsType = "btrfs";
      options = [ "subvol=@" "noatime" "compress=zstd:3" ];
    };

  fileSystems."/.btrfs/snapshot" =
    { device = "/dev/disk/by-uuid/23e9c9b8-d68a-4a09-9055-f2025919f28f";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" "noatime" "compress=zstd:3" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/23e9c9b8-d68a-4a09-9055-f2025919f28f";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress=zstd:3" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/23e9c9b8-d68a-4a09-9055-f2025919f28f";
      fsType = "btrfs";
      options = [ "subvol=@persist" "noatime" "compress=zstd:3" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/23e9c9b8-d68a-4a09-9055-f2025919f28f";
      fsType = "btrfs";
      options = [ "subvol=@log" "noatime" "compress=zstd:3" ];
      neededForBoot = true;
    };

  fileSystems."/.btrfs/volume" =
    { device = "/dev/disk/by-uuid/23e9c9b8-d68a-4a09-9055-f2025919f28f";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd:3" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/39F8-BF31";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/ea9fcb5f-edde-4873-8bfa-b1d7c134bdb4"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
