path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  cfgEndgame = config.celo.modules.servers.endgame;
  group = "server_static";
  nginx = util.nginx path config;
in
{
  imports = nginx.server {
    name = "static";
    endgame = true;
    locations = {
      "/" = {
        extraConfig = "autoindex on;";
        root = cfg.home;
      };

      "/private" = lib.mkIf nginx.endgame.isActive {
        extraConfig = "autoindex on;" + (nginx.endgame.extraConfig true);
        root = cfg.home;
      };
    };
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "Drop place for static files";
      default = "/srv/static";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      description = "Users that can modify the contents of static";
      default = [ config.celo.modules.core.user.userName ];
    };

    private = lib.mkOption {
      type = lib.types.either lib.types.bool (lib.types.listOf lib.types.singleLineStr);
      description = "Create a private location behind Endgame. If strings are passed, they are interpreted as whitelisted emails with access to the location";
      default = util.secret.rageOr config ./endgame/_secrets/email.rage cfgEndgame.enable;
      example = [ "email@domain.com" ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.nginx.enable;
        message = "Nginx needs to be enabled to serve static files";
      }
    ];

    users = lib.mkIf (builtins.length cfg.users > 0) {
      users = util.concatAttrs (map (u: { ${u}.extraGroups = lib.mkAfter [ group ]; }) cfg.users);
      groups.${group} = { };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [
        (
          if builtins.length cfg.users > 0 then
            {
              inherit group;
              directory = cfg.home;
              mode = "0775";
            }
          else
            cfg.home
        )
      ];
    };
  };
}
