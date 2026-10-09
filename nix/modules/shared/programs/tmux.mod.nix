path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  rootDir,
  ...
}:
let
  celo = config.celo.modules;
  cfg = util.getOptions path config;
  simpaltPkg = inputs.simpalt.packages.${pkgs.stdenv.hostPlatform.system}.tmux;
  hasCurrentlyPlaying = cfg.currentlyPlaying != "";
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
    simpalt = lib.mkEnableOption "simpalt status" // {
      default = true;
    };
  };

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = (hasCurrentlyPlaying -> !cfg.simpalt) && (cfg.simpalt -> !hasCurrentlyPlaying);
        message = "When simpalt is enabled, 'currentlyPlaying' has no impact";
      }
    ];

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
          text =
            if cfg.simpalt then
              ''exec ${simpaltPkg}/bin/simpalt-tmux s "$1"''
            else
              builtins.concatStringsSep "\n" [
                "#!${pkgs.bash}/bin/bash"
                (lib.optionalString (cfg.currentlyPlaying != "") ''
                  playing=$(${cfg.currentlyPlaying})
                  if [ -n "$playing" ]
                  then
                    echo -n "#[fg=colour234]#[fg=colour37,bg=colour234] ''${playing:0:64} "
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
