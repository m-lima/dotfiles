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
    endgame = util.secret.rageOr config ./endgame/_secrets/email.rage cfgEndgame.enable;
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
  };

  config = lib.mkIf cfg.enable {
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
