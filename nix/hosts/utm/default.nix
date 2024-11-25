{
  imports = [
    ./hardware-configuration.nix
  ];

  celo = {
    profiles.base.enable = true;

    modules = {
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
