{
  pkgs,
  lib,
  config,
  sysconfig,
  util,
  ...
}:
let
  cfg = sysconfig.modules.ui.programs.hyprland;
in util.mkIfUi sysconfig cfg.enable {
  home.packages = with pkgs; lib.mkAfter [
    bemenu
  ];

  programs = {
    bemenu = {
      enable = true;
      settings = {
        line-height = 28;
        list = "10 down";
        prompt = "open";
        ignorecase = true;
        width-factor = 0.3;

        tb = "#${cfg.color.background_dark}";
        tf = "#${cfg.color.accent}";

        fb = "#${cfg.color.background_dark}";
        ff = "#${cfg.color.foreground}";

        nb = "#${cfg.color.background_dark}";
        nf = "#${cfg.color.foreground}";

        hb = "#${cfg.color.background_dark}";
        hf = "#${cfg.color.accent}";

        ab = "#${cfg.color.background}";
        af = "#${cfg.color.accent}";
      };
    };
  };
}

