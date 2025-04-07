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
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = celo.programs.core.zsh.enable;
        message = "Nali enabled with ZSH disabled";
      }
    ];

    programs = {
      zsh.interactiveShellInit = ''
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
    };

    home-manager = util.withHome config {
      programs = {
        zsh.initExtra = ''
          compdef _bd bd
          compdef _vd vd
        '';
      };
    };
  };
}
