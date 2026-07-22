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
      disko.enable = true;
    };

    modules = {
      core = {
        disko = {
          device = "/dev/sda";
          legacy = true;
          luks = true;
          swap = "8G";
        };
        dropbear = {
          enable = true;
          port = util.secret.rage.orElse config ./_secrets/core/dropbear/port.rage 22;
        };
        impermanence = {
          retain.user.directories = [
            "code"
            "bin"
            "git"
          ];
        };
        system = {
          timeZone = "Europe/Amsterdam";
          stateVersion = "24.05";
        };
        user = {
          userName = "kinto";
          motd = ''
            [34m     _       _
             ___|_|_____| |_ _ _ ___
            |   | |     | . | | |_ -|
            |_|_|_|_|_|_|___|___|___|
            [m'';
        };
      };
      servers = {
        nginx = {
          enable = true;
          tls = true;
          baseHost = util.secret.rage.mkIf config ./_secrets/servers/nginx/baseHost.rage;
        };
        endgame = {
          enable = true;
          key = ./_secrets/servers/endgame/key.age;
        };
        cloud.enable = true;
        elo.enable = true;
        grafo.enable = true;
        ipe.enable = true;
        passer = {
          enable = true;
          extraDomains = util.secret.rage.mkIf config ./_secrets/servers/passer/domains.rage;
        };
        skull.enable = true;
        static.enable = true;
        criscelo = util.secret.rage.mkMapIf config ./_secrets/servers/criscelo/domain.rage (domain: {
          inherit domain;
          enable = true;
        });
      };
      services = {
        postgres = {
          enable = true;
          subvolume = false;
        };
        rustdesk = {
          enable = true;
          host = util.secret.rage.mkIf config ./_secrets/services/rustdesk/host.rage;
        };
        ssh = {
          enable = true;
          ports = util.secret.rage.mkIf config ./_secrets/services/ssh/ports.rage;
          security = "sshguard";
        };
      };
      programs = {
        direnv.enable = true;
        flakerpl.enable = true;
        nixshell.enable = true;
        simpalt = {
          symbol = "ɳ";
        };
      };
    };
  };
}
