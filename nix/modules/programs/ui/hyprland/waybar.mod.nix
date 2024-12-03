path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.hyprland;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    assertions = [ (util.assertHome config path) ];

    home-manager = util.withHome config {
      home.packages = with pkgs; [ waybar ];

      xdg.dataFile."waybar/power.sh" = {
        text = ''
          #!/usr/bin/env bash

          case $(echo 'Sleep
          Logoff
          Poweroff
          Reboot' | bemenu --prompt "") in
            Sleep) systemctl suspend ;;
            Logoff) hyprctl dispatch exit ;;
            Poweroff) systemctl poweroff ;;
            Reboot ) systemctl reboot ;;
          esac
        '';
        executable = true;
      };

      programs = {
        waybar = {
          enable = true;
          settings = {
            mainBar = {
              layer = "top";
              position = "top";
              height = 30;
              spacing = 10;

              modules-left = [ "hyprland/workspaces" ];
              modules-center = [ "hyprland/window" ];
              modules-right = [
                "idle_inhibitor"
                "network"
                "pulseaudio"
                "temperature"
                "cpu"
                "memory"
                "tray"
                "clock"
                "custom/power"
              ];

              "hyprland/workspaces" = {
                sort-by-number = true;
                on-scroll-up = "hyprctl dispatch workspace e-1";
                on-scroll-down = "hyprctl dispatch workspace e+1";
                format = "{icon}";
                format-icons = {
                  "1" = "";
                  "2" = "";
                  "3" = "";
                  "4" = "";
                  "5" = "󰿎";
                  "10" = "";
                };
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
                format-bluetooth = "{volume}% {icon}";
                format-bluetooth-muted = " ";
                format-muted = "";
                format-source = "{volume}% ";
                format-source-muted = "";
                format-icons = {
                  headphone = "";
                  hands-free = "󱡏";
                  headset = "";
                  phone = "";
                  portable = "󰺐";
                  car = "";
                  default = [
                    ""
                    ""
                    ""
                  ];
                };
                on-click = "pavucontrol";
              };

              temperature = {
                critical-threshold = 80;
                format = "{temperatureC}°C {icon}";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                ];
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

              "custom/power" = {
                format = "";
                on-click = "${
                  config.home-manager.users.${config.celo.modules.core.user.userName}.xdg.dataHome
                }/waybar/power.sh";
              };
            };
          };

          style = ''
            * {
              border: none;
              border-radius: 0;
              min-height: 0;
              font-family: "Hack Nerd Font Propo", Roboto, Helvetica, Arial, sans-serif;
            }

            window#waybar {
              color: #${cfg.color.foreground};
              text-shadow: 0 0 2px black;
              background-color: rgba(0, 0, 0, 0.2);

              transition-duration: 0.5s;
              transition-property: background-color;
            }

            #window {
              font-weight: bold;
            }

            #workspaces button {
              color: #${cfg.color.foreground};
            }

            #workspaces button:hover {
              color: #${cfg.color.background};
              background-color: #${cfg.color.accent};
            }

            #workspaces button.active {
              color: #${cfg.color.accent};
            }

            #workspaces button.urgent {
              color: #${cfg.color.accent_alt};
            }

            #custom-power {
              color: #${cfg.color.accent};
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
    };
  };
}
