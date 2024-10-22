{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/base.nix
  ];

  fileSystems = {
    "/persist".neededForBoot = true;
    "/var/log".neededForBoot = true;
  };
}
