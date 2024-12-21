path:
{
  lib,
  config,
  util,
  pkgs2405,
  ...
}:
let
  celo = config.celo.modules;
  cfg = util.getOptions path config;
  pkgs = pkgs2405;
in
{
  options = util.mkOptionsEnable path;

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = with pkgs; [ tmux ];

      xdg.configFile = {
        "tmux/tmux.conf".source = ../../../tmux/base.conf;
        "tmux/script/edit.zsh" = lib.mkIf celo.programs.core.zsh.enable {
          source = ../../../tmux/script/edit.zsh;
          executable = true;
        };
        "tmux/script/clear_scratches.sh" = {
          source = ../../../tmux/script/clear_scratches.sh;
          executable = true;
        };
        "tmux/script/condense_windows.sh" = {
          source = ../../../tmux/script/condense_windows.sh;
          executable = true;
        };
        "tmux/script/status_right.sh" = with builtins; {
          text =
            ''
              #!/usr/bin/env bash
            ''
            + lib.optionalString celo.programs.simpalt.enable readFile ../../../tmux/script/status/simpalt.sh
            # TODO
            # + (if cfg.enable then readFile ../../tmux/script/status/spotify.sh else "")
            + readFile ../../../tmux/script/status/time.sh;
          executable = true;
        };
      };
    };
  };
}
