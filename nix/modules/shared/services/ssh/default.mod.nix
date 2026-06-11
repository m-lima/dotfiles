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
  options = util.mkOptions path {
    listen = lib.mkEnableOption "listen for SSH connections" // {
      default = true;
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWz+qMP0BBpeBLzCCHxr4wLSNz8rGZpPvhoppP6zegF lima@silver"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHbQEGzU+WY8GwNy5Xwyx9BbyQvUhZ5yC4RNngB/pJeX celo@silverPhone"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXt8VCmaSB/ZAnZkld/yy59UcQOCV14nHCwOmLyIKE1 lima@BlackDiamond"
      ];
      description = ''
        A list of verbatim OpenSSH public keys that should be added to the
        user's authorized keys. The keys are added to a file that the SSH
        daemon reads in addition to the the user's authorized_keys file.
        You can combine the `keys` and
        `keyFiles` options.
        Warning: If you are using `NixOps` then don't use this
        option since it will replace the key required for deployment via ssh.
      '';
      example = [
        "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host"
        "ssh-ed25519 AAAAC3NzaCetcetera/etceteraJZMfk3QPfQ foo@bar"
      ];
    };
    authorizeNixHosts = lib.mkEnableOption "add known Nix hosts as authorized keys" // {
      default = true;
    };
    extraKeys = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            private = lib.mkOption {
              type = lib.types.path;
              description = "Private side of the key. Should be agenix encrypted and contain the `.age` extension";
            };
            public = lib.mkOption {
              type = lib.types.path;
              description = "Public side of the key. Should be agenix encrypted and contain the `.pub` extension";
            };
          };
        }
      );
      description = ''
        List of additional keypairs.
        The private and public side must share the same name, with different extensions.
        It is important to use a name recognizable by OpenSSH'';
      example = [
        {
          private = ./id_ed25519_key.age;
          public = ./id_ed25519_key.pub;
        }
      ];
      default = [ ];
    };
    extraHosts = (options.home-manager.users.type.getSubOptions [ ]).programs.ssh.settings;
  };

  config =
    let
      listToAttrs = mapper: list: builtins.listToAttrs (map mapper list);
      cleanName = suffix: name: lib.strings.removeSuffix suffix (builtins.baseNameOf name);
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = builtins.hasAttr "*" cfg.extraHosts == false;
          message = "Cannot use '*' as an extra host";
        }
        {
          assertion = builtins.all (
            k: (cleanName ".age" k.private) == (cleanName ".pub" k.public)
          ) cfg.extraKeys;
          message = "Extra keys must have have the same name, just different extensions `.age` and `.pub`";
        }
      ];

      services.openssh = lib.mkIf cfg.listen {
        enable = true;
      };

      users =
        let
          authorizedKeys =
            cfg.authorizedKeys
            ++ (lib.optionals cfg.authorizeNixHosts (
              map builtins.readFile (
                lib.flatten (
                  lib.mapAttrsToList (k: v: lib.optional (v == "regular" && lib.hasSuffix ".pub" k) ./_secrets/${k}) (
                    builtins.readDir ./_secrets
                  )
                )
              )
            ));
        in
        lib.mkIf (authorizedKeys != [ ]) {
          users =
            if user.enable then
              {
                ${user.userName} = {
                  openssh.authorizedKeys.keys = authorizedKeys;
                };
              }
            else
              {
                root = {
                  openssh.authorizedKeys.keys = authorizedKeys;
                };
              };
        };

      age.secrets = {
        ${util.secret.mkPath path secret} = lib.mkIf home.enable {
          rekeyFile = ./_secrets/${secret}.age;
          path = "${user.homeDirectory}/.ssh/id_ed25519";
          mode = "600";
          owner = user.userName;
          symlink = false;
        };
        ${util.secret.mkPath path "hosts"} = lib.mkIf home.enable {
          rekeyFile = ./_secrets/hosts.age;
          mode = "644";
          owner = user.userName;
        };
      }
      // (listToAttrs (name: {
        name = util.secret.mkPath path (builtins.baseNameOf name.private);
        value = {
          rekeyFile = name.private;
          path = "${user.homeDirectory}/.ssh/${cleanName ".age" name.private}";
          mode = "600";
          owner = user.userName;
          symlink = false;
        };
      }) cfg.extraKeys);

      home-manager = util.withHome config {
        home.file = {
          ".ssh/id_ed25519.pub".source = ./_secrets/${secret}.pub;
        }
        // (listToAttrs (name: {
          name = ".ssh/${builtins.baseNameOf name.public}";
          value = {
            source = name.public;
          };
        }) cfg.extraKeys);

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          includes = [ config.age.secrets.${util.secret.mkPath path "hosts"}.path ];
          settings = cfg.extraHosts // {
            "*" = {
              userKnownHostsFile = "~/.local/share/ssh/known_hosts";
            };
          };
        };
      };
    };
}
