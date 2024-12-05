{
  imports = [ ./hardware-configuration.nix ];

  celo = {
    profiles.base.enable = true;
    profiles.hyprland.enable = true;
    profiles.ui.enable = true;

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
        rage = {
          pubkey = ./ssh.key.pub;
        };
        user = {
          userName = "celo";
          homeDirectory = "/home/celo";
        };
      };
      hardware = {
        wifi.enable = true;
        bluetooth.enable = true;
      };
      programs = {
        simpalt = {
          symbol = "₵";
        };
      };
    };
  };
}
