{
  system = "aarch64-linux";
  module = {
    imports = [ ./hardware-configuration.nix ];

    celo = {
      profiles = {
        base.enable = true;
      };

      modules = {
        core = {
          disko = {
            device = "/dev/vda";
            swap = "1G";
          };
          nixos = {
            timeZone = "Europe/Amsterdam";
          };
        };
        programs = {
          core = {
            neovim = {
              plugins = [
                "lua"
                "nix"
              ];
            };
          };
          simpalt = {
            symbol = "μ";
          };
        };
      };
    };
  };
}
