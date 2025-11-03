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
  celo = config.celo.modules;
  cfgDisko = celo.core.disko;
in
{
  options = util.mkOptions path {
    retention = {
      hourly = lib.mkOption {
        description = "Hours to retain";
        type = lib.types.ints.u16;
        default = 48;
      };
      daily = lib.mkOption {
        description = "Days to retain";
        type = lib.types.ints.u16;
        default = 15;
      };
      weekly = lib.mkOption {
        description = "Weeks to retain";
        type = lib.types.ints.u16;
        default = 8;
      };
      monthly = lib.mkOption {
        description = "Months to retain";
        type = lib.types.ints.u16;
        default = 24;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfgDisko.enable;
        message = "snapper enabled without disko setup";
      }
    ];

    celo.modules.core.disko.mounts = lib.mkAfter {
      snapshots = {
        name = "@snapshots";
        mountpoint = "/.btrfs/snapshots";
      };
    };

    systemd = {
      services.snapper = {
        description = "snapper";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        startAt = "*-*-* *:01:00";
        wantedBy = [ "multi-user.target" ];
        script = ''
          function take_snapshot {
            name="$1"
            path="$2"
            now="$(date '+%Y-%m-%dT%H:%M:%S')"

            snap="${cfgDisko.mounts.snapshots.mountpoint}/$name"
            [ -d "$snap" ] || mkdir "$snap"
            snap="$snap/auto"
            [ -d "$snap" ] || mkdir "$snap"

            function trim {
              local target="$1"
              local limit="$2"
              local entries=($(ls -r "$target"))
              local deletables=("''${entries[@]:$limit}")
              local deletable

              for deletable in ''${deletables[@]}; do
                ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$target/$deletable"
              done
            }

            function create {
              local period="$1"
              local limit="$2"
              local target="$snap/$period"

              [ -d "$target" ] || mkdir "$target"

              ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r "$path" "$target/$now"
              trim "$target" "$limit"
            }

            function check {
              local period="$1"
              local pattern="$2"

              local target="$snap/$period"
              [ -d "$target" ] || return 0

              local entries=($(ls "$target"))
              [ "$entries" ] || return 0

              local last=$(date "$pattern" --date "''${entries[-1]}")
              local now=$(date "$pattern")

              [[ "$last" == "$now" ]] && return 1 || return 0
            }

            if check "hourly" "+%H"; then
              create "hourly" ${toString cfg.retention.hourly}
            fi

            if check "daily" "+%j"; then
              create "daily" ${toString cfg.retention.daily}
            fi

            if check "weekly" "+%V"; then
              create "weekly" ${toString cfg.retention.weekly}
            fi

            if check "monthly" "+%m"; then
              create "monthly" ${toString cfg.retention.monthly}
            fi
          }

          take_snapshot "root" "${cfgDisko.mounts.root.mountpoint}"
          ${lib.optionalString celo.core.impermanence.enable ''take_snapshot "persist" "${cfgDisko.mounts.persist.mountpoint}"''}
        '';
      };
    };
  };
}
