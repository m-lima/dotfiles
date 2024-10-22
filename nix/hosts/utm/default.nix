{
  disko,
  ...
}: {
  imports = [
    disko.nixosModules.disko
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/base.nix
  ];
}
