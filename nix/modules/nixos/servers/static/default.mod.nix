path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  group = "server_static";
  nginx = util.nginx path config;
in
{
  imports = nginx.server {
    name = "static";
    locations = {
      "/" = {
        extraConfig = "autoindex on;";
        root = cfg.home;
      };
    }
    // (lib.optionalAttrs cfg.withPrivate {
      "/private" = {
        extraConfig = "autoindex on;";
        root = cfg.home;
        endgame = {
          enable = true;
          autoLogin = true;
          whitelist = ./_secrets/users.age;
        };
      };
    });
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

    withPrivate = lib.mkEnableOption "private section under `/private`" // {
      default = true;
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
