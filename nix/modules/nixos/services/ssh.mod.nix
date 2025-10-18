path:
{
  lib,
  config,
  options,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  home = config.celo.modules.core.home;
  user = config.celo.modules.core.user;
  userGroup = config.users.users.${user.userName}.group;
  secret = config.celo.host.id;
  impermanence = config.celo.modules.core.impermanence;
in
{
  options = util.mkPath path {
    ports = options.services.openssh.ports;
    security = lib.mkOption {
      type = lib.types.enum [
        "none"
        "nopassword"
        "sshguard"
        "both"
      ];
      default = "nopassword";
      description = ''
        What method of security to use: block password logins, enable sshguard, both, or none
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      openssh = lib.mkIf cfg.listen {
        ports = cfg.ports;
        settings = lib.mkIf (cfg.security == "nopassword" || cfg.security == "both") {
          PasswordAuthentication = false;
        };
      };
      sshguard = lib.mkIf (cfg.security == "sshguard" || cfg.security == "both") {
        enable = true;
        services = lib.mkAfter [ "sshd-session" ];
      };
    };

    environment.persistence = util.withImpermanence config {
      global.files = [
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];

      home.directories = [ ".local/share/ssh" ];
    };

    systemd = lib.mkIf impermanence.enable {
      tmpfiles.rules = [
        "d ${user.homeDirectory}/.ssh 0755 ${user.userName} ${userGroup}"
      ];
    };

    age.secrets = {
      ${util.secret.mkPath path secret} = lib.mkIf home.enable {
        group = config.users.users.${user.userName}.group;
      };
      ${util.secret.mkPath path "hosts"} = lib.mkIf home.enable {
        group = config.users.users.${user.userName}.group;
      };
    };
  };
}
