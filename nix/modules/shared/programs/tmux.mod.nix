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
        "tmux/script/status_right.sh" = with builtins; {
          text =
            ''
              #!/usr/bin/env bash
            ''
            +
              lib.optionalString celo.programs.simpalt.enable readFile
                /${rootDir}/../tmux/script/status/simpalt.sh
            # TODO
            # + (lib.optionalString celo.programs.ui.spotify.enable (readFile /${rootDir}/../tmux/script/status/spotify.sh))
            + readFile /${rootDir}/../tmux/script/status/time.sh;
          executable = true;
        };
      };
    };
  };
}
