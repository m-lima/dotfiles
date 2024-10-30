{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = {
    disko = {
      luks = false;
      swap = "1G";
    };
    ui = true;
  };
}
