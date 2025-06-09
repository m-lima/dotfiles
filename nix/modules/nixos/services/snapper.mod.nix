path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  celo = config.celo.modules;
  diskoCfg = celo.core.disko;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = diskoCfg.enable;
        message = "snapper enabled without disko setup";
      }
      {
        assertion = celo.core.impermanence.enable;
        message = "snapper enabled without impermanence";
      }
    ];

    systemd = {
      # timers.snapper = {
      #   description = "Takes snapshots of the system's permanent subvolume";
      #   wantedBy = [ "timers.target" ];
      #   timerConfig = {
      #     Unit = "snapper.service";
      #     OnCalendar = "*-*-* *:01:00";
      #   };
      # };

      services.snapper = {
        description = "Takes snapshots of the system's permanent subvolume";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        startAt = "*-*-* *:01:00";
        wantedBy = [ "multi-user.target" ];
        script = ''
          set -eu

          path="${diskoCfg.mounts.persist}"
          snap="${diskoCfg.mounts.snapshots}/persist/auto"
          now="$(date '+%Y-%m-%dT%H:%M:%S')"

          [ -d "$snap" ] || mkdir "$snap"

          function trim {
            local target="$1"
            local limit="$2"
            local entries=($(ls -r "$target"))
            local deletables=("''${entries[@]:$limit}")
            local deletable

            for deletable in ''${deletables[@]}; do
              sudo btrfs subvolume delete "$target/$deletable"
            done
          }

          function create {
            local period="$1"
            local limit="$2"
            local target="$snap/$period"

            [ -d "$target" ] || mkdir "$target"

            sudo btrfs subvolume snapshot -r "$path" "$target/$now"
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
            create "hourly" 48
          fi

          if check "daily" "+%j"; then
            create "daily" 15
          fi

          if check "weekly" "+%V"; then
            create "weekly" 8
          fi

          if check "monthly" "+%m"; then
            create "monthly" 24
          fi
        '';
      };
    };
  };
}
