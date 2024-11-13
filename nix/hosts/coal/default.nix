{
  imports = [
    ./hardware-configuration.nix
  ];

  celo = {
    core = {
      disko = {
        enable = true;
        device = "/dev/nvme0n1";
        luks = true;
        swap = "8G";
      };
    };
  };

  modules = {
    disko = {
      device = "/dev/nvme0n1";
      luks = true;
      swap = "8G";
    };
    base = {
      hardware = {
        wireless = {
          enable = true;
        };
      };
    };
    ui = {
      enable = true;
    };
  };
}
