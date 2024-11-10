{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = {
    disko = {
      luks = true;
      swap = "8G";
    };
    ui = {
      enable = true;
    };
  };
}
