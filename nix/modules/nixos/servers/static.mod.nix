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
in
{
  imports = util.nginx path config "minimal" {
    name = "static";
    locations = {
      "/" = {
        extraConfig = "autoindex on;";
        root = cfg.home;
      };

      "/private" = lib.mkIf cfg.private {
        extraConfig = ''
          autoindex on;
          endgame on;
        '';
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

    private = lib.mkEnableOption "private route behind Endgame" // {
      default = cfgEndgame.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.nginx.enable;
        message = "Nginx needs to be enabled to serve static files";
      }
      {
        assertion = cfg.private -> cfgEndgame.enable;
        message = "Endgame needs to be enabled to serve the private route";
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
