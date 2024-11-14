{
  imports = [
    ./hardware-configuration.nix
  ];

  # modules = {
  #   disko = {
  #     device = "/dev/vda";
  #     luks = false;
  #     swap = "1G";
  #   };
  #   ui = {
  #     enable = true;
  #   };
  # };
  celo = {
    core = {
      disko = {
        enable = true;
        device = "/dev/vda";
        luks = false;
        swap = "1G";
      };
      impermanence = {
        enable = true;
        wipe = {
          enable = true;
        };
      };
      nixos = {
        enable = true;
        hostName = "utm";
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
    };
    programs = {
      curl.enable = true;
    };
    services = {
      ssh.enable = true;
    };
  };
}
