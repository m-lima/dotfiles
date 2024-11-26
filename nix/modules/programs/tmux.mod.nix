path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      (util.assertHome config path)
    ];

    home-manager = util.withHome config {
      home = {
        packages = with pkgs; [
          tmux
        ];

        file = {
          ".config/tmux/tmux.conf" = {
            source = ../../../tmux/base.conf;
          };
          ".config/tmux/script/edit.zsh" = util.mkIfProgram config "zsh" {
            source = ../../../tmux/script/edit.zsh;
            executable = true;
          };
          ".config/tmux/script/clear_scratches.sh" = {
            source = ../../../tmux/script/clear_scratches.sh;
            executable = true;
          };
          ".config/tmux/script/condense_windows.sh" = {
            source = ../../../tmux/script/condense_windows.sh;
            executable = true;
          };
          ".config/tmux/script/status_right.sh" = with builtins; {
            text = "#!/usr/bin/env bash"
              + lib.optionalString config.celo.modules.programs.simpalt.enable readFile ../../../tmux/script/status/simpalt.sh
              # TODO
              # + (if cfg.enable then readFile ../../tmux/script/status/spotify.sh else "")
              + readFile ../../../tmux/script/status/time.sh;
            executable = true;
          };
        };
      };
    };
  };
}
