path:
{
  lib,
  config,
  util,
options,
  ...
}:
let
  cfg = util.getOptions path config;
  home = config.celo.modules.core.user.home;
  user = config.celo.modules.core.user;
  secret = "${user.userName}-${config.celo.host.id}";
in
{
  options = util.mkOptions path {
    authorizedKeys =
      lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
      default = [];
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
        ./secrets/host/key.pub
      ];
    };
    authorizeNixHosts = lib.mkEnableOption "add known Nix hosts as authorized keys";
    ports = options.services.openssh.ports;
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = cfg.ports;
    };

    users =
     let authorizedKeys = cfg.authorizedKeys ++ (lib.optionals cfg.authorizeNixHosts (lib.flatten (
        lib.mapAttrsToList (k: v: lib.optional (v == "regular" && lib.hasSuffix ".pub" k) ./secrets/${k}) (
          builtins.readDir ./secrets
        )
      ))); in  lib.mkIf (authorizedKeys != [ ]) {
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
      # TODO: Move these to home-manager, for home-manager-only systems
      ${util.mkSecretPath path secret} = lib.mkIf home.enable {
        rekeyFile = ./secrets/${secret}.age;
        path = "${user.homeDirectory}/.ssh/id_ed25519";
        mode = "600";
        owner = user.userName;
        group = config.users.users.${user.userName}.group;
      };
      ${util.mkSecretPath path "hosts"} = lib.mkIf home.enable {
        rekeyFile = ./secrets/hosts.age;
        path = "${user.homeDirectory}/.ssh/config";
        mode = "644";
        owner = user.userName;
        group = config.users.users.${user.userName}.group;
      };
    };

    home-manager = util.withHome config {
      home.file = {
        ".ssh/id_ed25519.pub".source = ./secrets/${secret}.pub;
      };
    };

    environment.persistence = util.withImpermanence config {
      global.files = [
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];

      home.files = [ ".ssh/known_hosts" ];
    };
  };
}
