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
  cfg = util.getOptions path config;
  prg = config.celo.modules.programs;
  hackCfg = prg.ui.fonts.hack;
  tmuxCfg = prg.tmux;
in
{
  options = util.mkOptions path {
    tmuxStart = lib.mkEnableOption "wrap the terminal in a tmux session by default" // {
      default = tmuxCfg.enable;
    };
    pkg = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.package;
      default = pkgs.ghostty;
    };
    exec = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.str;
    };
  };

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = cfg.tmuxStart -> tmuxCfg.enable;
        message = "tmuxStart can only be used if tmux is present";
      }
    ];

    home-manager = {
      programs = {
        ghostty = {
          enable = true;
          enableZshIntegration = prg.zsh.enable;
          settings = {
            font-size = 11;

            quit-after-last-window-closed = true;
            quit-after-last-window-closed-delay = "5m";

            macos-option-as-alt = "left";
            macos-titlebar-style = "hidden";

            window-padding-balance = true;
            window-width = 122;
            window-height = 44;

            cursor-style = "block";
            cursor-style-blink = false;
            shell-integration-features = "no-cursor";
            cursor-invert-fg-bg = true;

            background = "#262626";
            foreground = "#839496";
            palette = [
              "0=#333333"
              "1=#dc322f"
              "2=#44a400"
              "3=#edb300"
              "4=#268bd2"
              "5=#d33682"
              "6=#009aa1"
              "7=#eee8d5"
              "8=#3c3c3c"
              "9=#ff3a36"
              "10=#60e800"
              "11=#fff204"
              "12=#5bbbff"
              "13=#c66cc1"
              "14=#00cac9"
              "15=#fdf6e3"
            ];
          }
          // (lib.optionalAttrs hackCfg.enable {
            font-family = "Hack";
          })
          // (lib.optionalAttrs cfg.tmuxStart {
            initial-command = "direct:${tmuxCfg.pkg}/bin/tmux new -A";
          });
        };
      };
    };
  };
}
