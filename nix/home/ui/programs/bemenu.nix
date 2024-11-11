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
        fb = "#1e1e2e";
        ff = "#cdd6f4";
        nb = "#1e1e2e";
        nf = "#cdd6f4";
        tb = "#1e1e2e";
        hb = "#1e1e2e";
        tf = "#f38ba8";
        hf = "#f9e2af";
        af = "#cdd6f4";
        ab = "#1e1e2e";
        width-factor = 0.3;
      };
    };
  };
}

