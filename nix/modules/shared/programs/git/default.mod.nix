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
  userName = celo.core.user.userName;
in
{
  options = util.mkOptions path {
    overrides = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.either (lib.types.coercedTo lib.types.singleLineStr (
          x: ./_secrets + ("/" + x)
        ) lib.types.path) (lib.types.attrsOf (lib.types.attrsOf lib.types.str))
      );
      description = ''
        Override a location gitconfig.
        If an attribute set is passed, the entries will become a literal configuration file.
        If a path is passed, it is interpreted as an agenix secret.
        If a string is passed, it is also interpreted as a secret, but whose source is relative to the git/_secrets location'';
      example = {
        "~/secret" = ./override.age;
        "~/relative/secret" = "override.age";
        "~/literal" = {
          user = {
            email = "other@email";
          };
        };
      };
      default = { };
    };
  };

  config =
    let
      md5 = builtins.hashString "md5";
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ git ];

      home-manager = util.withHome config {
        home.packages = with pkgs; [ git ];

        xdg.configFile =
          let
            toConfigFile = name: "git/${md5 name}";
            mapAttrsToLines = mapper: attrs: lib.concatStringsSep "\n" (lib.mapAttrsToList mapper attrs);
            parseOption = key: value: ''${key} = ${value}'';
            parseOptions = mapAttrsToLines parseOption;
            parseSection = key: value: ''
              [${key}]
              ${parseOptions value}
            '';
            parseSections = mapAttrsToLines parseSection;
            filterLiteral = lib.filterAttrs (_: builtins.isAttrs);
            intoXdgEntry = key: value: {
              name = "${toConfigFile key}";
              value = {
                text = parseSections value;
              };
            };
            createConfigs = overrides: lib.mapAttrs' intoXdgEntry (filterLiteral overrides);
            ensureTrailingSlash = path: if lib.hasSuffix "/" path then path else path + "/";
            intoInclude =
              key: value:
              ''
                [includeIf "gitdir:${ensureTrailingSlash key}"]
                	path = ''
              + (
                if builtins.isAttrs value then
                  "${config.home-manager.users.${userName}.xdg.configHome}/${toConfigFile key}"
                else
                  "${config.age.secrets.${util.mkSecretPath path (md5 key)}.path}"
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
          zsh.initContent = util.extractCompdef (
            builtins.readFile /${rootDir}/../zsh/config/programs/git.zsh
          );
        };
      };

      programs = lib.mkIf celo.programs.zsh.enable {
        zsh.interactiveShellInit = builtins.readFile /${rootDir}/../zsh/config/programs/git.zsh;
      };

      age.secrets = lib.mapAttrs' (key: value: {
        name = util.mkSecretPath path (md5 key);
        value = {
          rekeyFile = value;
          owner = userName;
        };
      }) (lib.filterAttrs (_: builtins.isPath) cfg.overrides);
    };
}
