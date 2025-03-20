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
            # + (lib.optionalString celo.programs.ui.spotify.enable (readFile ../../../tmux/script/status/spotify.sh))
            + readFile ../../../tmux/script/status/time.sh;
          executable = true;
        };
      };
    };
  };
}
