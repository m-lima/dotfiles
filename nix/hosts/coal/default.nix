{
  imports = [
    ./hardware-configuration.nix
  ];

  celo = {
    profiles.base.enable = true;
    profiles.hyprland.enable = true;

    modules = {
      core = {
        disko = {
          device = "/dev/nvme0n1";
          luks = true;
          swap = "8G";
        };
        nixos = {
          hostName = "coal";
          timeZone = "Europe/Amsterdam";
        };
        user = {
          userName = "celo";
          homeDirectory = "/home/celo";
        };
      };
      network = {
        wireless.enable = true;
      };
      programs = {
        simpalt = {
          symbol = "₵";
        };
      };
    };
  };
}
