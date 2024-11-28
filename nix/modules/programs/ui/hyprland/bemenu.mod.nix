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
in {
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [
      (util.assertHome config path)
    ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [
        bemenu
      ];

      programs = {
        bemenu = {
          enable = true;
          settings = {
            prompt = "Open";
            ignorecase = true;

            center = true;
            line-height = 28;
            list = "10 down";
            width-factor = 0.3;

            tb = "#${hyprCfg.color.background}";
            tf = "#${hyprCfg.color.accent_alt}";

            fb = "#${hyprCfg.color.background}";
            ff = "#${hyprCfg.color.foreground}";

            nb = "#${hyprCfg.color.background_dark}";
            nf = "#${hyprCfg.color.foreground}";

            ab = "#${hyprCfg.color.background_dark}";
            af = "#${hyprCfg.color.foreground}";

            hb = "#${hyprCfg.color.background_dark}";
            hf = "#${hyprCfg.color.accent}";
          };
        };
      };
    };
  };
}
