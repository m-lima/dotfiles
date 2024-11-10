{
  imports = [
    ./hardware-configuration.nix
  ];

  modules = {
    disko = {
      device = "/dev/nvme0n1";
      luks = true;
      swap = "8G";
    };
    ui = {
      enable = true;
    };
  };
}
