{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  modules.impermanence = {
    enable = true;
    # TODO: Derive from disko
    device = "/dev/vda3";
  };
}
