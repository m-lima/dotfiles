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
  hyprCfg = config.celo.modules.programs.ui.hyprland;
in
{
  options = util.mkOptions path {
    startTmux = lib.mkEnableOption "Wrap the terminal in a tmux session by default";
  };

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = cfg.startTmux -> config.celo.modules.programs.tmux.enable;
        message = "startTmux can only be used if tmux is present";
      }
    ];

    home-manager = {
      home = {
        packages = with pkgs; [ alacritty ];
      };

      xdg.configFile."alacritty/alacritty.toml".text =
        ''''
        + builtins.readFile ../../../../alacritty/config/colors.toml
        + builtins.readFile ../../../../alacritty/config/font.toml
        + builtins.readFile ../../../../alacritty/config/options.toml
        + (lib.optionalString cfg.startTmux ''
          [shell]
          program = "tmux"
        '');

      wayland.windowManager.hyprland = lib.mkIf hyprCfg.enable {
        settings = {
          "$terminal" = "alacritty";
        };
      };
    };
  };
}
