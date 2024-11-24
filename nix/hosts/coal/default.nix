{
  imports = [
    ./hardware-configuration.nix
  ];

  celo = {
    profile.base.enable = true;

    module = {
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
    };
  };
}
