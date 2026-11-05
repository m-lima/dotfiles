path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  cfg = util.getOptions path config;
  nginx = util.nginx path config;
  name = "rando";
  rando = inputs.rando.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = nginx.server {
    inherit name;
    extras = [
      (nginx.extras.proxy {
        socket = "unix:/run/${name}/socket";
      })
    ];
  };

  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    systemd = {
      services.rando = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        description = "Rando";
        serviceConfig = util.systemd.harden {
          Type = "simple";
          ExecStart = builtins.concatStringsSep " " [
            "${rando}/bin/rando"
            "--socket ${toString cfg.socket}"
            "-vvv"
          ];
          Restart = "on-failure";
          TimeoutSec = 15;

          UMask = "0000";

          RestrictAddressFamilies = [ "AF_UNIX" ];
          RuntimeDirectory = name;
        };
      };
    };
  };
}
