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

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home.packages = with pkgs; [ waybar ];

      # Fix for start ordering
      # By default the Unit starts after `graphical-session-pre`
      # However hyprland starts after UWSM and only after `graphical-session`
      # So this manaually sets the service to start after UWSM
      systemd.user.services.waybar.Unit.After = lib.mkForce "graphical-session.target";

      programs = {
        waybar = {
          enable = true;
          systemd.enable = true;
          settings = {
            mainBar = {
              layer = "top";
              position = "top";

              modules-left = [ "hyprland/window" ];
              modules-center = [ "hyprland/workspaces" ];
              modules-right = [
                "group/media"
                "group/hardware"
                "tray"
                "clock"
                "custom/power"
              ];

              "group/media" = {
                orientation = "inherit";
                modules = [
                  "custom/player"
                  "pulseaudio"
                ];
              };

              "group/hardware" = {
                orientation = "inherit";
                modules = [
                  "network"
                  "temperature"
                  "cpu"
                  "memory"
                  "idle_inhibitor"
                ];
              };

              "hyprland/workspaces" = {
                sort-by-number = true;
                on-scroll-up = "hyprctl dispatch workspace e-1";
                on-scroll-down = "hyprctl dispatch workspace e+1";
              };

              "custom/player" = {
                interval = 1;
                return-type = "json";
                format = "{}";
                format-alt = "{} {alt}";
                tooltip-format = "{alt}";
                exec = "${
                  config.home-manager.users.${config.celo.modules.core.user.userName}.xdg.dataHome
                }/hypr/player.sh";
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
                tooltip-format-wifi = "󰈀 {ifname}\n󰌘 {ipaddr}\n {essid}\n󱂇 {gwaddr}";
                tooltip-format-ethernet = " {ifname}\n󰌘 {ipaddr}\n󱂇 {gwaddr}";
                tooltip-format-disconnected = "⚠ Disconnected";
              };

              pulseaudio = {
                format = "{icon} {volume}%";
                format-bluetooth = "{icon} {volume}%";
                format-bluetooth-muted = " ";
                format-muted = "";
                format-source = " {volume}%";
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
                format = "{icon}";
                format-alt = "{icon} {temperatureC}°C";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                ];
                tooltip-format = "{temperatureC}°C";
              };

              cpu = {
                format = "";
                format-alt = " {usage}%";
              };

              memory = {
                format = "";
                format-alt = " {}%";
                tooltip-format = ''
                  {percentage}%
                  {used}
                  {avail}'';
              };

              clock = {
                format = "{:%H:%M}";
                format-alt = "{:%a, %d. %b %H:%M}";
              };

              tray = {
                spacing = 10;
              };

              "custom/power" = {
                format = "";
                on-click = "${
                  config.home-manager.users.${config.celo.modules.core.user.userName}.xdg.dataHome
                }/hypr/power.sh";
              };
            };
          };

          style = ''
            * {
              border: none;
              border-radius: 0;
              background: none;
              min-height: 0;
              font-family: "Hack Nerd Font Propo", Roboto, Helvetica, Arial, sans-serif;
            }

            window#waybar {
              color: #${cfg.color.foreground};
              text-shadow: 0 0 2px black;
              background-color: rgba(0, 0, 0, 0.2);

              transition-duration: 0.5s;
              transition-property: all;
            }

            .modules-left,
            .modules-center,
            .modules-right
            {
              margin: 4px;
            }

            #window,
            #workspaces,
            #media,
            #hardware
            {
              background-color: rgba(0, 0, 0, 0.6);
              border-radius: 30px;
              padding: 4px;
            }

            .modules-left *,
            .modules-right *,
            #window *,
            #media *,
            #hardware *,
            #workspaces *
            {
              margin-top: 0;
              margin-bottom: 0;
              margin-left: 4px;
              margin-right: 4px;
              padding: 0;
            }

            #window {
              font-weight: bold;
            }

            #workspaces button {
              background-color: #${cfg.color.background};
              color: #${cfg.color.background};
              border-radius: 30px;
            }

            #workspaces button.active {
              padding-right: 10px;
              padding-left: 10px;
            }

            #workspaces button.urgent {
              color: #${cfg.color.background};
              background-color: #${cfg.color.accent_alt};
            }

            #workspaces button:hover {
              box-shadow: inherit;
              text-shadow: inherit;
              color: #${cfg.color.background};
              background-color: #${cfg.color.accent};
            }

            #custom-power {
              color: #${cfg.color.accent};
            }
          '';
        };
      };
    };
  };
}
