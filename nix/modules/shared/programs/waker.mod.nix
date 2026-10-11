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
in
{
  options = util.mkOptions path {
    hosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            mac = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "MAC address of the host to wake";
              example = "00:00:00:00:00:00";
            };
            ip = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "IP address of the host to wake";
              example = "10.0.0.0";
            };
          };
        }
      );
      description = "Possible hosts to connect to";
      example = {
        yo = {
          mac = "00:00:00:00:00:00";
          ip = "10.0.0.0";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.length (builtins.attrNames cfg.hosts) > 0;
        message = "There should be at least one host configured";
      }
    ];

    environment.systemPackages =
      let
        availableHosts = lib.concatStringsSep "\n" (
          map (n: "echo '${n} - ${cfg.hosts.${n}.mac} ${cfg.hosts.${n}.ip}'") (builtins.attrNames cfg.hosts)
        );
        hostVars = lib.concatStringsSep "\n" (
          map (n: "HOST_${n}='${cfg.hosts.${n}.mac} -i ${cfg.hosts.${n}.ip}'") (builtins.attrNames cfg.hosts)
        );
      in
      [
        (pkgs.writeShellScriptBin "waker" ''
          if [ $1 ]; then
            PKG="$1"
          else
            echo 'No host provided provided'
            echo
            echo 'Available hosts:'
            ${availableHosts}
            exit 1
          fi

          ${hostVars}
          host=HOST_$1
          args="''${!host}"

          if [ -z "$args" ]; then
            echo 'Invalid host provided'
            echo
            echo 'Available hosts:'
            ${availableHosts}
            exit 1
          fi

          exec ${pkgs.wakeonlan}/bin/wakeonlan ''${!host}
        '')
      ];
  };
}
