{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/base.nix
  ];
}
