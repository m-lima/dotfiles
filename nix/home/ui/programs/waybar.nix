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
          spacing = 10;

          modules-left = [
           "hyprland/workspaces"
          ];
          modules-center = [
            "hyprland/window"
          ];
          modules-right = [
            "idle_inhibitor"
            "network"
            "pulseaudio"
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

          network = {
            format-wifi = "";
            format-ethernet = "󰈀";
            format-linked = "󰌙";
            format-disconnected = "⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format-ethernet = " {ifname}\n󰌘 {ipaddr}\n󱂇 {gwaddr}";
            tooltip-format-wifi = "󰈀 {ifname}\n󰌘 {ipaddr}\n {essid}\n󱂇 {gwaddr}";
          };

          pulseaudio = {
            format = "{volume}% {icon}";
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
            format = "{}% ";
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
        * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: "Hack Nerd Font Mono", Roboto, Helvetica, Arial, sans-serif;
        }

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

        #pulseaudio {
          border-bottom: 1px solid rgba(255, 255, 0, 0.5);
        }

        #temperature {
          border-bottom: 1px solid rgba(255, 0, 0, 0.5);
        }

        #cpu {
          border-bottom: 1px solid rgba(0, 255, 0, 0.5);
        }

        #memory {
          border-bottom: 1px solid rgba(0, 0, 255, 0.5);
        }
      '';
    };
  };
}
