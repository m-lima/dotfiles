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
    assertions = [ (util.assertHome path config) ];

    home-manager = util.withHome config {
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