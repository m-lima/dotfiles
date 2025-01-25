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
in
{
  options = util.mkOptions path {
    port = options.boot.initrd.network.ssh.port;
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWz+qMP0BBpeBLzCCHxr4wLSNz8rGZpPvhoppP6zegF lima@silver"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIoQfGlWPRvuEcqapM3zOmvppowN9x+jF2LgfEl150hS celo@silvercog"
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
    authorizeWheel = lib.mkEnableOption "add wheel users as authorized keys" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.celo.modules.core.disko.enable && config.celo.modules.core.disko.luks;
        message = "Disko LUKS encryption is disabled";
      }
    ];

    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        port = cfg.port;
        authorizedKeys =
          cfg.authorizedKeys
          ++ (lib.optionals cfg.authorizeWheel (
            lib.concatLists (
              lib.mapAttrsToList (
                name: user: if lib.elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else [ ]
              ) config.users.users
            )
          ));
        hostKeys = [
          config.age.secrets.${util.mkSecretPath path config.celo.host.id}.path
        ];
      };
      postCommands = ''
        echo 'cryptsetup-askpass' >> /root/.profile
      '';
    };

    age.secrets = {
      ${util.mkSecretPath path config.celo.host.id} = {
        rekeyFile = ./secrets/${config.celo.host.id}.age;
      };
    };
  };
}
