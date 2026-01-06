{
  config,
  util,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  celo = {
    profiles = {
      system.enable = true;
      base.enable = true;
      core.enable = true;
      dev.enable = true;
      disko.enable = true;
    };

    modules = {
      core = {
        disko = {
          device = "/dev/vda";
          swap = "1G";
        };
        system = {
          timeZone = "Europe/Amsterdam";
          stateVersion = "24.05";
        };
      };
      services = {
        keyring.enable = true;
        mdns.enable = true;
        ssh = {
          enable = true;
          ports = [ 22 ] ++ (util.secret.rage config ./_secrets/services/ssh/ports.rage);
        };
      };
      programs = {
        simpalt = {
          symbol = "μ";
        };
        skull.enable = true;
      };
    };
  };
}
