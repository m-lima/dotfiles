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
  secret = config.celo.host.id;
in
{
  options = util.mkPath path {
    ports = options.services.openssh.ports;
  };

  config = lib.mkIf cfg.enable {
    services.openssh = lib.mkIf cfg.listen {
      ports = cfg.ports;
    };

    environment.persistence = util.withImpermanence config {
      global.files = [
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];

      home.files = [ ".ssh/known_hosts" ];
    };

    age.secrets = {
      ${util.mkSecretPath path secret} = lib.mkIf home.enable {
        group = config.users.users.${user.userName}.group;
      };
      ${util.mkSecretPath path "hosts"} = lib.mkIf home.enable {
        group = config.users.users.${user.userName}.group;
      };
    };
  };
}
