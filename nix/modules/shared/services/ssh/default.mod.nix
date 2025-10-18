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
      type = lib.types.listOf lib.types.path;
      description = ''
        List of additional keypairs.
        The path will have '.age' appended and treated as the private side with agenix, and will have '.pub' appended for the public side.
        It is important to use a name recognizable by OpenSSH'';
      example = [ ./id_ed25519_key ];
      default = [ ];
    };
  };

  config =
    let
      listToAttrs = mapper: list: builtins.listToAttrs (map mapper cfg.extraKeys);
    in
    lib.mkIf cfg.enable {
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
          path = "${user.homeDirectory}/.ssh/config";
          mode = "644";
          owner = user.userName;
          symlink = false;
        };
      }
      // (listToAttrs (name: {
        name = util.secret.mkPath path (builtins.baseNameOf name);
        value = {
          rekeyFile = name + ".age";
          path = "${user.homeDirectory}/.ssh/${builtins.baseNameOf name}";
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
          name = ".ssh/${builtins.baseNameOf name}.pub";
          value = {
            source = name + ".pub";
          };
        }) cfg.extraKeys);
      };
    };
}
