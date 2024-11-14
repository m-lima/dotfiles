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
    alacritty
  ];

  home.file = {
    ".config/alacritty/alacritty.toml" = with builtins; {
      text = ''
        [font]
          normal = { family = "Hack Nerd Font Mono", style = "Regular" }
          bold = { style = "Bold" }
          bold_italic = { style = "Bold Italic" }
          italic = { style = "Italic" }
        '' + readFile ../../../../alacritty/config/colors.toml;
    };
  };
}

