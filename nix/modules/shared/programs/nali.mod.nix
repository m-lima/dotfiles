path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  celo = config.celo.modules;
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    entries = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Entries to navigate to with `td`";
      default = {
        cd = "~/code";
        nx = "~/code/dotfiles/nix";
      };
      example = {
        cd = "~/code";
        df = "~/code/dotfiles";
      };
    };
  };

  config =
    let
      script = ''
        setopt auto_pushd
        setopt pushd_ignore_dups
        setopt pushdminus

        setopt auto_pushd
        setopt pushd_ignore_dups
        setopt pushdminus

        function bd {
          if [[ "$1" =~ '^[0-9]+$' ]]
          then
            cd -$1 > /dev/null
          else
            cd - > /dev/null
          fi
        }

        function _bd {
          if ((CURRENT == 2))
          then
            # Setting the tag to indexes and disabling grouping
            zstyle ":completion:''${curcontext}:indexes" list-grouped no

            local lines i list

            # Allowing $HOME to be replaced
            lines=("''${(D)dirstack[@]}")
            list=()
            integer i

            # The list is the format "value:description"
            for (( i = 1; i <= $#lines; i++ ))
            do
              list+="$i:$lines[$i]"
            done

            # -V disables the ordering
            _describe -V 'history indices' list
          fi
        }

        compdef _bd bd

        function vd {
          if [[ "$1" =~ '^[0-9]+$' ]]
          then
            local it=$1
          else
            local it=1
          fi

          until [ $it -eq 0 ]
          do
            local BACK=../$BACK
            (( it-- ))
          done

          cd $BACK
        }

        function _vd {
          if ((CURRENT == 2))
          then
            # Setting the tag to indexes and disabling grouping
            zstyle ":completion:''${curcontext}:indexes" list-grouped no

            local lines i list

            # Slipting the path by "/"
            lines=(''${(s:/:)PWD})
            list=()
            integer i

            # The list is the format "value:description"
            for (( i = 2; i <= $#lines; i++ ))
            do
              list+="$((i-1)):$lines[-$i]"
            done

            # -V disables the ordering
            _describe -V 'directory stack' list
          fi
        }

        compdef _vd vd
      '';
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = celo.programs.zsh.enable;
          message = "nali enabled without zsh";
        }
        {
          assertion = cfg.entries != { } -> celo.core.home.enable;
          message = "nali entries defined without home-manager";
        }
      ];

      programs = {
        zsh.interactiveShellInit = script;
      };

      home-manager =
        let
          td = lib.optionalString (cfg.entries != { }) ''
            function td {
              if [ "$1" ]
              then
                case "$1" in
                  ${lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (k: v: ''${k}) eval cd "${v}/$2"; return ;;'') cfg.entries
                  )}
                esac

                echo Entry not found
                return -1
              else
                cd ~
              fi
            }

            function _td {
              if (( CURRENT == 2 ))
              then
                local list=( ${
                  lib.concatStringsSep " " (lib.mapAttrsToList (k: v: ''"${k}:${v}"'') cfg.entries)
                } )
                _describe 'targets' list
              elif (( CURRENT == 3 ))
              then
                case "$words[2]" in
                  ${lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (k: v: ''${k}) eval _path_files -W "${v}" -/; return ;;'') cfg.entries
                  )}
                esac
              fi
            }

            compdef _td td
          '';
        in
        util.withHome config {
          programs = {
            zsh.initContent = (util.extractCompdef script) + "\n${td}";
          };
        };
    };
}
