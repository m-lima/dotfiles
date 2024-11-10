{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = {
    disko = {
      device = "/dev/vda";
      luks = false;
      swap = "1G";
    };
    ui = {
      enable = true;
    };
  };
}
