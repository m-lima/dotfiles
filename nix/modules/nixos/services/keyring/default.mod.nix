path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  host = config.celo.host.id;
  user = config.celo.modules.core.user;
  kdeCfg = config.celo.modules.programs.ui.kde;
in
{
  options = util.mkOptions path {
    components = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "pkcs11"
          "secrets"
          "ssh"
        ]
      );
      default = [ "secrets" ];
      description = ''
        The GNOME keyring components to start. If empty then the
        default set of components will be started.
      '';
    };
  };

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = !kdeCfg.enable;
        message = "Conflicting secret manager with KWallet from KDE";
      }
    ];

    environment.persistence = util.withImpermanence config {
      home.directories = [ ".local/share/keyrings" ];
    };

    age.secrets = {
      ${util.mkSecretPath path "password"} = {
        rekeyFile = ./_secrets/${host}/password.age;
        mode = "600";
        owner = user.userName;
        group = config.users.users.${user.userName}.group;
      };
    };

    home-manager =
      let
        gnome-keyring-daemon-start = pkgs.writeShellScriptBin "gnome-keyring-daemon-start" (
          "exec ${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon --foreground --unlock"
          + lib.optionalString (cfg.components != [ ]) (
            " --components=" + lib.concatStringsSep "," cfg.components
          )
          + " < ${config.age.secrets.${util.mkSecretPath path "password"}.path}"
        );
      in
      {
        home.packages = with pkgs; [
          gnome.gnome-keyring
          gnome-keyring-daemon-start
        ];

        systemd.user.services.gnome-keyring = {
          Unit = {
            Description = "GNOME Keyring Daemon";
            After = [ "default.target" ];
          };
          Service = {
            ExecStart = "${gnome-keyring-daemon-start}/bin/gnome-keyring-daemon-start";
            Restart = "on-abort";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };

  };
}
