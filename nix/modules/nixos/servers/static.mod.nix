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
in
{
  imports = util.nginx path config "minimal" {
    name = "static";
    locations = {
      "/" = {
        extraConfig = "autoindex on;";
        root = cfg.home;
      };
    };
  };

  options = util.mkOptions path {
    home = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "/srv/static";
      description = "Drop place for static files";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = [ config.celo.modules.core.user.userName ];
      description = "Users that can modify the contents of static";
    };
  };

  config = {
    assertions = [
      {
        assertion = config.services.nginx.enable;
        message = "Nginx needs to be enabled to server static files";
      }
    ];

    users = lib.mkIf (builtins.length cfg.users > 0) {
      users = builtins.foldl' (acc: curr: acc // curr) { } (
        map (u: { ${u}.extraGroups = lib.mkAfter [ group ]; }) cfg.users
      );
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
