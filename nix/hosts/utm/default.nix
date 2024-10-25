{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = {
    impermanence.enable = true;
    disko.luks = false;
  };
}
