path:
{
  lib,
  config,
  options,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  nginx = util.nginx path config;
  socket = "/run/grafana/socket";
in
{
  imports = nginx.server {
    name = "grafo";
    endgame = util.secret.rage config /${rootDir}/secrets/general/email.rage;
    extraConfig = nginx.endgame.extraConfig true;
    extras = [
      (nginx.extras.proxy {
        socket = "unix:/var${socket}";
      })
      (nginx.extras.proxy {
        location = "/api/live/";
        socket = "unix:/var${socket}";
        ws = true;
      })
    ];
  };

  options = util.mkOptions path {
    retention = lib.mkOption {
      type = lib.types.int;
      description = "Retention of the timeseries data in days";
      default = 90;
    };

    scrapers = {
      nginx = lib.mkOption {
        type = lib.types.bool;
        default = config.celo.modules.servers.nginx.enable;
      };
      wifidog = lib.mkOption {
        type = lib.types.bool;
        default = config.celo.modules.services.wifidog.enable;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = {
      telegraf.extraGroups = [
        "nextcloud"
        "nginx"
      ];
      ${config.services.nginx.user}.extraGroups = [ "grafana" ];
    };

    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            protocol = "socket";
            socket = socket;
            socket_mode = "0660";
          };

          security = {
            admin_email = builtins.head cfg.endgame;
          };

          users = {
            viewers_can_edit = true;
          };

          auth = {
            disable_login_form = true;
          };

          "auth.proxy" = {
            enabled = true;
            header_name = "X-EMAIL";
            header_property = "email";
            auto_sign_up = false;
            headers = "Name:X-GIVEN-NAME";
            enable_login_token = false;
          };
        };

        provision = {
          enable = true;

          datasources.settings.datasources = [
            {
              name = "InfluxDB";
              type = "influxdb";
              access = "proxy";
              url = "http://127.0.0.1:8086";
              database = "telegraf";
              isDefault = true;

              jsonData = {
                httpMode = "GET";
              };
            }
          ];
        };
      };

      influxdb.enable = true;

      telegraf = {
        enable = true;
        extraConfig = {
          outputs = {
            influxdb = [
              {
                urls = [ "http://127.0.0.1:8086" ];
                database = "telegraf";
              }
            ];
          };

          inputs = {
            cpu = [
              {
                percpu = true;
                totalcpu = true;
                collect_cpu_time = false;
                report_active = true;
                core_tags = false;
              }
            ];
            disk = [ { } ];
            mem = [ { } ];
            net = [ { } ];
            system = [ { } ];

            nginx = lib.optional cfg.scrapers.nginx { urls = [ "http://127.0.0.1/nginx_status" ]; };

            socket_listener = lib.optional cfg.scrapers.wifidog {
              service_address = "unixgram:///var/run/telegraf/telegraf.sock";
              socket_mode = "0660";
              data_format = "influx";
            };
          };
        };
      };
    };

    systemd.services = {
      influxdb-setup = {
        description = "Setup InfluxDB Databases and Retention";
        wantedBy = [ "multi-user.target" ];
        requires = [ "influxdb.service" ];
        after = [ "influxdb.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script =
          let
            influx = "${pkgs.influxdb}/bin/influx -execute";
          in
          ''
            echo "Waiting for InfluxDB storage engine to be fully ready..."
            until ${influx} 'SHOW DATABASES' > /dev/null 2>&1; do
              sleep 1
            done

            ${influx} 'CREATE DATABASE "telegraf"'
            ${influx} 'ALTER RETENTION POLICY "autogen" ON "telegraf" DURATION ${toString cfg.retention}d SHARD DURATION ${
              if cfg.retention < 3 then
                "1h"
              else if cfg.retention < 30 then
                "1d"
              else
                "7d"
            } DEFAULT'
          '';
      };
    };

    environment = {
      persistence = util.withImpermanence config {
        global.directories =
          let
            influxdb = config.services.influxdb;
          in
          [
            {
              directory = influxdb.dataDir;
              user = influxdb.user;
              group = influxdb.group;
              mode = "0755";
            }
          ];
      };
    };
  };
}
