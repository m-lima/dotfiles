path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  celo = config.celo.modules;
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    pkg = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.package;
      default = pkgs.tmux;
    };
    currentlyPlaying = lib.mkOption {
      type = lib.types.str;
      description = "Script to the currently playing media";
      default = "";
    };
  };

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = [ cfg.pkg ];

      xdg.configFile = {
        "tmux/tmux.conf".source = /${rootDir}/../tmux/base.conf;
        "tmux/script/edit.zsh" = lib.mkIf celo.programs.zsh.enable {
          source = /${rootDir}/../tmux/script/edit.zsh;
          executable = true;
        };
        "tmux/script/clear_scratches.sh" = {
          source = /${rootDir}/../tmux/script/clear_scratches.sh;
          executable = true;
        };
        "tmux/script/condense_windows.sh" = {
          source = /${rootDir}/../tmux/script/condense_windows.sh;
          executable = true;
        };
        "tmux/script/status_right.sh" = {
          text = builtins.concatStringsSep "\n" [
            "#!${pkgs.bash}/bin/bash"
            (lib.optionalString celo.programs.simpalt.enable builtins.readFile
              /${rootDir}/../tmux/script/status/simpalt.sh
            )
            (lib.optionalString (cfg.currentlyPlaying != "") ''
              playing=$(${cfg.currentlyPlaying})
              if [ -n "$playing" ]
              then
                echo -n "#[fg=colour234]#[fg=colour37,bg=colour234] $playing "
              fi
            '')
            (builtins.readFile /${rootDir}/../tmux/script/status/time.sh)
          ];
          executable = true;
        };
      };
    };
  };
}
