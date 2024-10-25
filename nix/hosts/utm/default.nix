{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  modules = {
    impermanence.enable = true;
  };
}
