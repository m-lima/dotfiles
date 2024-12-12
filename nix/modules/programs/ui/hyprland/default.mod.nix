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
in
{
  options = util.mkOptions path {
    color = {
      foreground = util.mkColorOption "foreground" "cccccc";
      background = util.mkColorOption "background" "333333";
      background_dark = util.mkColorOption "background" "222222";
      accent = util.mkColorOption "accent" "ffa500";
      accent_alt = util.mkColorOption "accent" "d33682";
    };
    size = {
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
      border = {
        radius = lib.mkOption {
          type = lib.types.ints.u8;
          description = "Corner radius";
          default = 4;
          example = 12;
        };
      };
    };
    wallpaper = lib.mkOption {
      type = lib.types.path;
      description = "Wallpaper path";
      default = ./res/background.jpg;
      example = ./res/background.jpg;
    };
  };

  config = util.enforceHome path config cfg.enable {
    programs = {
      hyprland = {
        enable = true;
        withUWSM = true;
      };
    };

    home-manager = {
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;

        settings = {
          "$fileManager" = "dolphin";
          "$launcher" = "fuzzel";

          env = [
            "QT_QPA_PLATFORM,wayland"
            "QT_QPA_PLATFORMTHEME,qt5ct"
          ];

          animations = {
            enabled = false;
          };

          input = {
            kb_layout = "us";
            # Don't refocus on mouse hover
            follow_mouse = 2;
          };

          general = {
            gaps_in = cfg.size.gap.inner;
            gaps_out = cfg.size.gap.outer;

            "col.active_border" = "rgb(${cfg.color.accent})";
            "col.inactive_border" = "rgb(${cfg.color.background})";

            layout = "dwindle";
          };

          decoration = {
            rounding = cfg.size.border.radius;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          binds = {
            allow_workspace_cycles = true;
          };

          bind =
            let
              hyprData = config.home-manager.users.${config.celo.modules.core.user.userName}.xdg.dataHome;
            in
            [
              # Top-level commands
              "SUPER,       SPACE,  exec,               $launcher"
              "SUPER SHIFT, W,                          killactive"
              "SUPER SHIFT, Q,      exec,               ${hyprData}/hypr/power.sh"

              # Applications
              "SUPER, RETURN, exec, $terminal"
              "SUPER, N,      exec, $browser"
              "SUPER, M,      exec, $player"
              "SUPER, E,      exec, $fileManager"

              # Layout
              "SUPER,         F, fullscreen,             1"
              "SUPER SHIFT,   F, fullscreen"
              "SUPER CONTROl, F, togglefloating"
              "SUPER,         S, togglespecialworkspace, magic"
              "SUPER SHIFT,   S, movetoworkspace,        special:magic"
              "SUPER,         D, togglesplit"

              # Movement
              "SUPER,       H, movefocus,  l"
              "SUPER,       J, movefocus,  d"
              "SUPER,       K, movefocus,  u"
              "SUPER,       L, movefocus,  r"
              "SUPER SHIFT, H, swapwindow, l"
              "SUPER SHIFT, J, swapwindow, d"
              "SUPER SHIFT, K, swapwindow, u"
              "SUPER SHIFT, L, swapwindow, r"

              # Workspaces
              "SUPER, GRAVE, workspace, previous"
              "SUPER, 1,     workspace, 1"
              "SUPER, 2,     workspace, 2"
              "SUPER, 3,     workspace, 3"
              "SUPER, 4,     workspace, 4"
              "SUPER, 5,     workspace, 5"
              "SUPER, 6,     workspace, 6"
              "SUPER, 7,     workspace, 7"
              "SUPER, 8,     workspace, 8"
              "SUPER, 9,     workspace, 9"
              "SUPER, 0,     workspace, 10"

              "SUPER SHIFT, GRAVE, movetoworkspace, previous"
              "SUPER SHIFT, 1,     movetoworkspace, 1"
              "SUPER SHIFT, 2,     movetoworkspace, 2"
              "SUPER SHIFT, 3,     movetoworkspace, 3"
              "SUPER SHIFT, 4,     movetoworkspace, 4"
              "SUPER SHIFT, 5,     movetoworkspace, 5"
              "SUPER SHIFT, 6,     movetoworkspace, 6"
              "SUPER SHIFT, 7,     movetoworkspace, 7"
              "SUPER SHIFT, 8,     movetoworkspace, 8"
              "SUPER SHIFT, 9,     movetoworkspace, 9"
              "SUPER SHIFT, 0,     movetoworkspace, 10"
            ];

          bindm = [
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];

          binde = [
            "SUPER CONTROL, H, resizeactive, -10   0"
            "SUPER CONTROL, J, resizeactive,   0 -10"
            "SUPER CONTROL, K, resizeactive,   0  10"
            "SUPER CONTROL, L, resizeactive,  10   0"
          ];

          bindel = [
            ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume      @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute,        exec, wpctl set-mute        @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioPlay,        exec, playerctl -p playerctld play-pause"
            ",XF86AudioPrev,        exec, playerctl -p playerctld previous"
            ",XF86AudioNext,        exec, playerctl -p playerctld next"
          ];

          workspace = [
            # Emulate smart gaps
            "w[tv1], gapsout:0, gapsin:0"
            "f[1],   gapsout:0, gapsin:0"
          ];

          windowrulev2 = [
            # Emulate smart gaps
            "bordersize 0, floating:0, onworkspace:w[tv1]"
            "rounding 0,   floating:0, onworkspace:w[tv1]"
            "bordersize 0, floating:0, onworkspace:f[1]"
            "rounding 0,   floating:0, onworkspace:f[1]"
          ];
        };
      };
    };
  };
}
