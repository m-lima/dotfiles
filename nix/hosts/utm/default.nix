{ ... }:
let
  btrfsDevice = "/dev/vda3";
in {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/base.nix
  ];
}
