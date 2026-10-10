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
  xdg = util.xdg config;
  home = config.celo.modules.core.home;
  user = config.celo.modules.core.user;
  userGroup = config.users.users.${user.userName}.group;
  secret = config.celo.host.id;
  impermanence = config.celo.modules.core.impermanence;
  hasTotp = builtins.isPath cfg.totp;
in
{
  options = util.mkPath path {
    ports = options.services.openssh.ports;
    totp = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Agenix encrypted file for the TOTP configuration.
        Can be generated with `nix-shell -p google-authenticator --run google-authenticator`.

        Recommended settings:
        * Enable rate-limit
        * Disable timeskew compensation
        * Disable reuse
      '';
    };
    sshguard = lib.mkEnableOption "SSH guard" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      openssh = lib.mkIf cfg.listen {
        ports = cfg.ports;
        settings = {
          PasswordAuthentication = false;
        }
        // (lib.optionalAttrs hasTotp {
          KbdInteractiveAuthentication = true;
        });
      };
      sshguard = lib.mkIf cfg.sshguard {
        enable = true;
        services = lib.mkAfter [ "sshd-session" ];
      };
    };

    security.pam.services.sshd = lib.mkIf hasTotp {
      googleAuthenticator.enable = true;
      unixAuth = lib.mkForce true;
    };

    environment.persistence = util.withImpermanence config {
      global.files = [
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];

      home.directories = [ "${xdg.rel "dataHome"}/ssh" ];
    };

    systemd = lib.mkIf impermanence.enable {
      tmpfiles.rules = [ "d ${user.homeDirectory}/.ssh 0755 ${user.userName} ${userGroup}" ];
    };

    age.secrets = {
      ${util.secret.mkPath path secret} = lib.mkIf home.enable {
        group = userGroup;
      };
      ${util.secret.mkPath path "hosts"} = lib.mkIf home.enable {
        group = userGroup;
      };
      ${util.secret.mkPath path "totp"} = lib.mkIf hasTotp {
        rekeyFile = cfg.totp;
        owner = user.userName;
        group = userGroup;
        mode = "400";
        path = "${user.homeDirectory}/.google_authenticator";
        symlink = false;
      };
    };
  };
}
