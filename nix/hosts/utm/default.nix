{
  imports = [
    ./hardware-configuration.nix
  ];

  celo = {
    profile.base.enable = true;

    module = {
      core = {
        disko = {
          device = "/dev/vda";
          swap = "1G";
        };
        nixos = {
          hostName = "utm";
          timeZone = "Europe/Amsterdam";
        };
        user = {
          userName = "celo";
          homeDirectory = "/home/celo";
        };
      };
    };
  };
}
