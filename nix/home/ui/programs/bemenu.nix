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
        prompt = "Open";
        ignorecase = true;

        center = true;
        line-height = 28;
        list = "10 down";
        width-factor = 0.3;

        tb = "#${cfg.color.background}";
        tf = "#${cfg.color.accent_alt}";

        fb = "#${cfg.color.background}";
        ff = "#${cfg.color.foreground}";

        nb = "#${cfg.color.background_dark}";
        nf = "#${cfg.color.foreground}";

        ab = "#${cfg.color.background_dark}";
        af = "#${cfg.color.foreground}";

        hb = "#${cfg.color.background_dark}";
        hf = "#${cfg.color.accent}";
      };
    };
  };
}

