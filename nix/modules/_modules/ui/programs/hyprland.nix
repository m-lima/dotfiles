{
  pkgs,
  lib,
  config,
  util,
  ...
}:
let
  cfg = config.modules.ui.programs.hyprland;
in {
  # Using an unstable module
  # imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/programs/wayland/uwsm" ];

  options = {
    modules.ui.programs.hyprland = {
      enable = util.mkDisableOption "hyprland";
      sddm = {
        enable = util.mkDisableOption "SDDM";
      };
      color = {
        foreground = util.mkColorOption "foreground" "cccccc";
        background = util.mkColorOption "background" "333333";
        background_dark = util.mkColorOption "background" "222222";
        accent = util.mkColorOption "accent" "ffa500";
        accent_alt = util.mkColorOption "accent" "d33682";
      };
      gap = {
        outer = lib.mkOption {
          type = lib.types.ints.u8;
          description = "Outer gap in pixels";
          default = 8;
          example = 12;
        };
        inner = lib.mkOption {
          type = lib.types.ints.u8;
          description = "Inner gap in pixels";
          default = 4;
          example = 12;
        };
      };
      wallpaper = lib.mkOption {
        type = lib.types.path;
        description = "Wallpaper path";
        default = ./res/background.jpg;
        example = ./res/background.jpg;
      };
    };
  };

  config = util.mkIfUi config cfg.enable {
    programs.hyprland = {
      enable = true;
    };

    services.displayManager.sddm = lib.mkIf cfg.sddm.enable {
      enable = true;
      wayland.enable = true;
      # TODO: The TTY changes, causing a blank screen
      sugarCandyNix = {
        enable = true;
        settings = {
          Background = lib.cleanSource cfg.wallpaper;
          ScreenWidth = 3840;
          ScreenHeight = 2160;
          FullBlur = true;
          MainColor = "#${cfg.color.foreground}";
          BackgroundColor = "#${cfg.color.background}";
          AccentColor = "#${cfg.color.accent}";
          OverrideLoginButtonTextColor = "#${cfg.color.background}";
          ForceHideCompletePassword = true;
        };
      };
    };
  };
}