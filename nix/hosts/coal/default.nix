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
      impermanence = {
        enable = true;
        wipe = {
          enable = true;
        };
      };
      nixos = {
        enable = true;
        hostName = "coal";
        timeZone = "Europe/Amsterdam";
      };
      user = {
        enable = true;
        userName = "celo";
        homeDirectory = "/home/celo";
        home.enable = true;
      };
    };
    network = {
      mdns.enable = true;
      wireless.enable = true;
    };
    programs = {
      curl.enable = true;
    };
    services = {
      ssh.enable = true;
    };
  };

  # modules = {
  #   disko = {
  #     device = "/dev/nvme0n1";
  #     luks = true;
  #     swap = "8G";
  #   };
  #   base = {
  #     hardware = {
  #       wireless = {
  #         enable = true;
  #       };
  #     };
  #   };
  #   ui = {
  #     enable = true;
  #   };
  # };
}
