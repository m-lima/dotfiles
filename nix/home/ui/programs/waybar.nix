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
    waybar
  ];

  programs = {
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          spacing = 4;

          modules-left = [
           "hyprland/workspaces"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            "network"
            "temperature"
            "cpu"
            "memory"
            "tray"
            "clock"
          ];

          "hyprland/workspaces" = {
            sort-by-number = true;
            on-scroll-up = "hyprctl dispatch workspace e-1";
            on-scroll-down = "hyprctl dispatch workspace e+1";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = "󰝟 {icon} {format_source}";
            format-muted = "󰝟 {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "󱡏";
              headset = "";
              phone = "";
              portable = "󰺐";
              car = "";
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} 󰈀";
            tooltip-format = "{ifname} via {gwaddr} 󱂇";
            format-linked = "{ifname} (No IP) 󰌙";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = ["" "" "" ""];
          };

          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };

          memory = {
            format = "{}% ";
          };

          clock = {
            format = "{:%a, %d. %b %H:%M}";
            format-alt = "{%H:%M}";
          };

          tray = {
            spacing = 10;
          };

        };
      };

      style = ''
        window#waybar {
          color: #${cfg.color.foreground};
          text-shadow: 0 0 4px black;
          background-color: rgba(0, 0, 0, 0.2);

          transition-duration: 0.5s;
          transition-property: background-color;
        }

        .modules-left,
        .modules-right
        {
          padding-right: ${toString cfg.gap.outer}px;
          padding-left: ${toString cfg.gap.outer}px;
        }
      '';
    };
  };
}
