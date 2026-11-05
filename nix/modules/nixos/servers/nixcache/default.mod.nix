path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  nginx = util.nginx path config;
  key = "cache-key";
in
{
  imports = nginx.server {
    name = "nix";
    extras = [
      (nginx.extras.proxy {
        socket = config.services.nix-serve.port;
      })
    ];
  };

  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    age.secrets = {
      ${util.secret.mkPath path key} = {
        rekeyFile = ./_secrets/${key}.age;
      };
    };

    nix.settings."trusted-users" = [
      "root"
      config.celo.modules.core.user.userName
    ];

    services.nix-serve = {
      enable = true;
      secretKeyFile = config.age.secrets.${util.secret.mkPath path key}.path;
    };
  };
}
