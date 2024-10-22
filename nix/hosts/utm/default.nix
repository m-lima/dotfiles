{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../modules/base.nix
    ../../modules/impermanence.nix
  ];

  modules.impermanence = {
    enable = true;
    device = "/dev/vda3";
  };
}
