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
      default = { };
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
          assertion = celo.programs.core.zsh.enable;
          message = "nali enabled without zsh";
        }
        {
          assertion = cfg.entries != {} -> celo.core.user.home.enable;
          message = "nali entries defined without home-manager";
        }
      ];

      programs = {
        zsh.interactiveShellInit = script;
      };

      home-manager = util.withHome config (
        if cfg.entries == { } then
          {
            programs = {
              zsh.initExtra = util.extractCompdef script;
            };
          }
        else
          let
            entries = pkgs.writeTextDir "td/config" (
              lib.concatStrings (lib.mapAttrsToList (k: v: "${k}:${v}\n") cfg.entries)
            );
          in
          {
            home.packages = [ entries ];
            programs = {
              zsh.initExtra =
                (util.extractCompdef script)
                + ''

                  function td {
                    if [ "$1" ]
                    then
                      while read line
                      do
                        local entry="''${line%%:*}"
                        if [[ "$entry" == "$1" ]]
                        then
                          local dir="''${line#*:}"
                          eval cd "$dir/$2"
                          return
                        fi
                      done < "${entries}/td/config"
                      echo Entry not found
                      return -1
                    else
                      cd ~
                    fi
                  }

                  function _td {
                    if (( CURRENT == 2 ))
                    then
                      local list=($(cat "${entries}/td/config"))
                      _describe 'targets' list

                    elif (( CURRENT == 3 ))
                    then

                      while read line
                      do
                        if [[ "$(echo $line | cut -d : -f 1)" == "$words[2]" ]]
                        then
                          eval _path_files -W $(echo $line | cut -d : -f 2) -/
                          return
                        fi
                      done < "${entries}/td/config"
                    fi
                  }

                  compdef _td td
                '';
            };
          }
      );
    };
}
