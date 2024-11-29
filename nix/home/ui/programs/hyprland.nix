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
in
util.mkIfUi sysconfig cfg.enable {
  home.packages =
    with pkgs;
    lib.mkAfter [
      bemenu
      dolphin
    ];

  # qt = {
  #   enable = true;
  #   platformTheme = {
  #     name = "qtct";
  #   };
  #   style = {
  #     name = "breeze";
  #     package = with pkgs; [
  #       breeze-icons
  #       breeze-qt5
  #     ];
  #   };
  # };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$terminal" = "alacritty";
      "$fileManager" = "dolphin";
      "$launcher" = "bemenu-run";
      "$browser" = "firefox";

      exec-once = [ "hyprpaper & waybar" ];

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
        gaps_in = cfg.gap.inner;
        gaps_out = cfg.gap.outer;

        # TODO: Add very small radius

        "col.active_border" = "rgb(${cfg.color.accent})";
        "col.inactive_border" = "rgb(${cfg.color.background})";

        layout = "dwindle";
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

      bind = [
        # Top-level commands
        "SUPER SHIFT, Q,                          exit"
        "SUPER,       W,                          killactive"
        "SUPER,       SPACE,  exec,               $launcher"

        # Applications
        "SUPER,       RETURN, exec, [workspace 1] $browser"
        "SUPER SHIFT, RETURN, exec,               $browser"
        "SUPER,       ESCAPE, exec, [workspace 3] $terminal"
        "SUPER SHIFT, ESCAPE, exec,               $terminal"
        "SUPER,       E,      exec, [workspace 4] $fileManager"
        "SUPER SHIFT, E,      exec,               $fileManager"

        # Layout
        "SUPER,       F, fullscreen"
        "SUPER SHIFT, F, togglefloating"
        "SUPER,       S, togglespecialworkspace, magic"
        "SUPER SHIFT, S, movetoworkspace, special:magic"
        "SUPER,       D, togglesplit"

        # Movement
        "SUPER,       H, movefocus, l"
        "SUPER,       J, movefocus, d"
        "SUPER,       K, movefocus, u"
        "SUPER,       L, movefocus, r"
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

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume      @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,        exec, wpctl set-mute        @DEFAULT_AUDIO_SINK@ toggle"
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

        # Organize the windows
        # TODO: Verify classes
        "maximize,    class:^(firefox)$"
        "workspace 1, class:^(firefox)$"
      ];
    };
  };
}
