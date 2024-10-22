{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/base.nix
    (import ../../modules/impermanence.nix { btrfsDevice = "/dev/vda3"; })
  ];
}
