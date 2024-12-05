{
  imports = [ ./hardware-configuration.nix ];

  celo = {
    profiles.base.enable = true;

    modules = {
      core = {
        hostName = "utm";
        agenix = {
          pubkey = ./ssh.key.pub;
        };
        disko = {
          device = "/dev/vda";
          swap = "1G";
        };
        nixos = {
          timeZone = "Europe/Amsterdam";
        };
        user = {
          userName = "celo";
          homeDirectory = "/home/celo";
        };
      };
      programs = {
        simpalt = {
          symbol = "μ";
        };
      };
    };
  };
}
