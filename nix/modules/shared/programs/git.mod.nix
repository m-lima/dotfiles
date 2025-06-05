path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  celo = config.celo.modules;
  user = celo.core.user.userName;
in
{
  options = util.mkOptions path {
    overrides = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.either lib.types.path (lib.types.attrsOf (lib.types.attrsOf lib.types.str))
      );
      description = "Override a location gitconfig";
      example = {
        "~/code/other" = ./otherConfig;
        "~/code/fork" = {
          user = {
            email = "other@email";
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ git ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [ git ];

      xdg.configFile =
        let
          toConfigFile = name: "git/${builtins.hashString "md5" name}";
          mapAttrsToLines = mapper: attrs: lib.concatStringsSep "\n" (lib.mapAttrsToList mapper attrs);
          parseOption = key: value: ''${key} = ${value}'';
          parseOptions = mapAttrsToLines parseOption;
          parseSection = key: value: ''
            [${key}]
            ${parseOptions value}
          '';
          parseSections = mapAttrsToLines parseSection;
          filterLiteral = lib.filterAttrs (_: lib.isAttrs);
          intoXdgEntry = key: value: {
            name = "${toConfigFile key}";
            value = {
              text = parseSections value;
            };
          };
          createConfigs = overrides: lib.mapAttrs' intoXdgEntry (filterLiteral overrides);
          intoInclude =
            key: value:
            ''
              [includeIf "gitdir:${key}"]
              	path = ''
            + (
              if lib.isAttrs value then
                "${config.home-manager.users.${user}.xdg.configHome}/${toConfigFile key}"
              else
                "${config.age.secrets.${util.mkSecretPath path key}.path}"
            );
          includeOverrides = mapAttrsToLines intoInclude;
        in
        {
          "git/config".text =
            builtins.readFile /${rootDir}/../git/config/gitconfig
            + (lib.optionalString config.celo.modules.services.ssh.enable (
              builtins.readFile /${rootDir}/../git/config/sign
            ))
            + (includeOverrides cfg.overrides);
          "git/ignore".text = builtins.readFile /${rootDir}/../git/config/ignore;
        }
        // (createConfigs cfg.overrides);

      programs = lib.mkIf celo.programs.zsh.enable {
        zsh.initExtra = util.extractCompdef (builtins.readFile /${rootDir}/../zsh/config/programs/git.zsh);
      };
    };

    programs = lib.mkIf celo.programs.zsh.enable {
      zsh.interactiveShellInit = builtins.readFile /${rootDir}/../zsh/config/programs/git.zsh;
    };

    age.secrets = lib.mapAttrs' (key: value: {
      name = util.mkSecretPath path key;
      value = {
        rekeyFile = value;
      };
    }) (lib.filterAttrs (_: lib.isPath) cfg.overrides);
  };
}
