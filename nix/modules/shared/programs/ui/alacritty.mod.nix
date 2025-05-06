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
  hackCfg = config.celo.modules.programs.ui.fonts.hack;
  tmuxCfg = config.celo.modules.programs.tmux;
in
{
  options = util.mkOptions path {
    tmuxStart = lib.mkEnableOption "wrap the terminal in a tmux session by default";
    pkg = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.package;
      default = pkgs.alacritty;
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
      home = {
        packages = [ cfg.pkg ];
      };

      xdg.configFile."alacritty/alacritty.toml".text =
        ''''
        + builtins.readFile /${rootDir}/../alacritty/config/colors.toml
        + builtins.readFile /${rootDir}/../alacritty/config/options.toml
        + (lib.optionalString hackCfg.enable (builtins.readFile /${rootDir}/../alacritty/config/font.toml))
        + (lib.optionalString cfg.tmuxStart ''
          [env]
          TERM = "alacritty-direct"
          [terminal]
          shell = { program = "${pkgs.bash}/bin/bash", args = ["-l", "-c", "${tmuxCfg.pkg}/bin/tmux"] }
        '');
    };
  };
}
