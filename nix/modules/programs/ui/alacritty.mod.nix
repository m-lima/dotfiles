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
  hackCfg = config.celo.modules.programs.ui.fonts.hack;
  hyprCfg = config.celo.modules.programs.ui.hyprland;
  tmuxCfg = config.celo.modules.programs.tmux;
in
{
  options = util.mkOptions path {
    tmuxStart = lib.mkEnableOption "wrap the terminal in a tmux session by default";
  };

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = cfg.tmuxStart -> tmuxCfg.enable;
        message = "tmuxStart can only be used if tmux is present";
      }
    ];

    home-manager = {
      home = {
        packages = with pkgs; [ alacritty ];
      };

      xdg.configFile."alacritty/alacritty.toml".text =
        ''''
        + builtins.readFile ../../../../alacritty/config/colors.toml
        + builtins.readFile ../../../../alacritty/config/options.toml
        + (lib.optionalString hackCfg.enable (builtins.readFile ../../../../alacritty/config/font.toml))
        + (lib.optionalString cfg.tmuxStart ''
          [env]
          TERM = "alacritty-direct"
          [terminal]
          shell = "tmux"
        '');

      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$terminal" = "alacritty";
        };
      };
    };
  };
}
