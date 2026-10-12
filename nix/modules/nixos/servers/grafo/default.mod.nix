path:
{
  lib,
  config,
  options,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
  cfgCloud = config.celo.modules.servers.cloud;
  secret = util.secret.mkPath path;
  nginx = util.nginx path config;
  socket = "/run/grafana/socket";
  influxdbSocket = "/run/influxdb/socket";
in
{
  imports = nginx.server {
    name = "grafo";
    endgame =
      if cfg.disableAuth then
        null
      else
        {
          enable = true;
          autoLogin = true;
          whitelist = ./_secrets/users.age;
        };
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
    disableAuth = lib.mkEnableOption "disable endgame login and allow all users";

    retention = lib.mkOption {
      type = lib.types.int;
      description = "Retention of the timeseries data in days";
      default = 90;
    };

    scrapers = {
      cloud = lib.mkOption {
        type = lib.types.bool;
        default = cfgCloud.enable;
      };
      nginx = lib.mkOption {
        type = lib.types.bool;
        default = config.celo.modules.servers.nginx.enable;
      };
      wifidog = lib.mkOption {
        type = lib.types.bool;
        default = config.celo.modules.services.wifidog.enable;
      };
    };

    loki = lib.mkEnableOption "redirecting logs to Loki";
  };

  config = lib.mkIf cfg.enable {
    users.users = {
      telegraf.extraGroups = [
        "nextcloud"
        "nginx"
        "influxdb"
      ];
      ${config.services.nginx.user}.extraGroups = [ "grafana" ];
    };

    age.secrets = {
      ${secret "adminEmail"} = {
        rekeyFile = ./_secrets/adminEmail.age;
        owner = "grafana";
        group = "grafana";
      };
      ${secret "cloudToken"} = lib.mkIf cfg.scrapers.cloud {
        rekeyFile = ./_secrets/cloudToken.age;
      };
      ${secret "grafanaKey"} = {
        rekeyFile = ./_secrets/grafanaKey.age;
        owner = "grafana";
        group = "grafana";
      };
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
            admin_email = "$__file{${config.age.secrets.${secret "adminEmail"}.path}}";
            secret_key = "$__file{${config.age.secrets.${secret "grafanaKey"}.path}}";
          };

          users = {
            viewers_can_edit = true;
          };

          auth = {
            disable_login_form = true;
          };
        }
        // (
          if cfg.disableAuth then
            {
              "auth.anonymous" = {
                enabled = true;
                org_role = "Editor";
              };
            }
          else
            {
              "auth.proxy" = {
                enabled = true;
                header_name = "X-EMAIL";
                header_property = "email";
                auto_sign_up = false;
                headers = "Name:X-GIVEN-NAME";
                enable_login_token = false;
              };
            }
        );

        provision = {
          enable = true;

          datasources.settings.datasources = [
            {
              name = "InfluxDB";
              type = "influxdb";
              access = "proxy";
              url = "http://127.0.0.1:8086";
              uid = "influxdb-local";
              database = "telegraf";
              isDefault = true;

              jsonData = {
                httpMode = "GET";
              };
            }
          ]
          ++ (lib.optional cfg.loki {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:3100";
            uid = "loki-local";
          });

          dashboards.settings.providers = [
            {
              name = "overview";
              disableDeletion = true;
              options = {
                path = "/etc/grafana-dashboards";
                foldersFromFilesStructure = true;
              };
            }
          ];
        };
      };

      influxdb = {
        enable = true;
        settings = {
          http = {
            unix-socket-enabled = true;
            bind-socket = influxdbSocket;
          };
        };
      };

      telegraf = {
        enable = true;

        environmentFiles = lib.mkIf cfg.scrapers.cloud [ config.age.secrets.${secret "cloudToken"}.path ];

        extraConfig = {
          outputs = {
            influxdb = [
              {
                urls = [ "unix://${influxdbSocket}" ];
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

            nginx = lib.mkIf cfg.scrapers.nginx [ { urls = [ "http://127.0.0.1/nginx_status" ]; } ];

            socket_listener = lib.mkIf cfg.scrapers.wifidog [
              {
                service_address = "unixgram:///var/run/telegraf/telegraf.sock";
                socket_mode = "0660";
                data_format = "influx";
              }
            ];

            http = lib.mkIf cfg.scrapers.cloud [
              {
                urls = [
                  "https://${cfgCloud.hostName}.${cfgCloud.domain}/ocs/v2.php/apps/serverinfo/api/v1/info?format=json"
                ];
                method = "GET";
                headers = {
                  NC-Token = "$TELEGRAF_TOKEN";
                };
                data_format = "json";
                json_query = "ocs.data";
                name_prefix = "nextcloud_";
                success_status_codes = [ 200 ];
              }
            ];
          };
        };
      };

      alloy = lib.mkIf cfg.loki {
        enable = true;
        extraFlags = [
          "--disable-reporting"
        ];
        configPath = pkgs.writeText "config.alloy" ''
          discovery.relabel "journal_metadata" {
            targets = []

            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
            }

            rule {
              source_labels = ["__journal_syslog_identifier"]
              target_label  = "service_name"
            }

            rule {
              source_labels = ["__journal_priority"]
              target_label  = "level"
            }

            rule {
              source_labels = ["unit"]
              regex = "^nginx\\.service$"
              target_label = "service_name"
              replacement = "nginx"
            }
          }

          loki.source.journal "read" {
            relabel_rules = discovery.relabel.journal_metadata.rules
            forward_to    = [loki.write.local.receiver]
            labels = {
              job  = "systemd-journal",
              host = "localhost",
            }
          }

          loki.write "local" {
            endpoint {
              url = "http://127.0.0.1:3100/loki/api/v1/push"
            }
          }
        '';
      };

      loki = lib.mkIf cfg.loki {
        enable = true;

        configuration =
          let
            dataDir = config.services.loki.dataDir;
          in
          {
            auth_enabled = false;

            server = {
              http_listen_port = 3100;
              grpc_listen_port = 9096;
              log_level = "info";
              grpc_server_max_concurrent_streams = 1000;
            };

            common = {
              instance_addr = "127.0.0.1";
              path_prefix = dataDir;
              storage.filesystem = {
                chunks_directory = "${dataDir}/chunks";
                rules_directory = "${dataDir}/rules";
              };
              replication_factor = 1;
              ring.kvstore.store = "inmemory";
            };

            query_range.results_cache.cache.embedded_cache = {
              enabled = true;
              max_size_mb = 100;
            };

            limits_config = {
              metric_aggregation_enabled = true;
              enable_multi_variant_queries = true;
              retention_period = "${toString (cfg.retention * 24)}h";
            };

            compactor = {
              working_directory = "${dataDir}/compactor";
              compaction_interval = "10m";
              retention_enabled = true;
              retention_delete_delay = "2h";
              retention_delete_worker_count = 150;
              delete_request_store = "filesystem";
            };

            schema_config.configs = [
              {
                from = "2020-01-01";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];

            pattern_ingester = {
              enabled = true;
              metric_aggregation.loki_address = "localhost:3100";
            };

            frontend = {
              encoding = "protobuf";
            };

            analytics.reporting_enabled = false;
          };

      };

      journald = lib.mkIf cfg.loki {
        extraConfig = ''
          MaxFileSec=1day
          MaxRetentionSec=${
            if cfg.retention <= 7 then
              "1day"
            else if cfg.retention <= 30 then
              "7day"
            else
              "1month"
          }
        '';
      };

    };

    systemd = {
      services = {
        telegraf = {
          serviceConfig = util.systemd.base // {
            ProcSubset = "all";
            ProtectProc = "default";

            IPAddressAllow = "localhost";
            PrivateNetwork = false;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_NETLINK"
              "AF_UNIX"
            ];
          };
        };

        influxdb = {
          serviceConfig = util.systemd.base // {
            RuntimeDirectory = "influxdb";
            RuntimeDirectoryMode = "0755";

            ReadWritePaths = [ "/var/db/influxdb" ];

            IPAddressAllow = "localhost";
            PrivateNetwork = false;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];
          };
        };

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

        influx-nixos-rebuild = {
          description = "Push NixOS rebuild actions to InfluxDB";

          after = [
            "influxdb.service"
            "network.target"
          ];
          requires = [ "influxdb.service" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
          };

          script = ''
            if [ -f /run/nixos-rebuild/action ]; then
              REBUILD="$(< /run/nixos-rebuild/action)"

              if [ -f /run/nixos-rebuild/action-old ] && [[ "$REBUILD" == "$(< /run/nixos-rebuild/action-old)" ]]; then
                echo "No changes detected"
                exit 0
              fi

              ACTION="''${REBUILD%	*}"
              STORE="''${REBUILD#*	}"
            fi

            [ -z "$ACTION" ] && ACTION="boot"
            [ -z "$STORE" ] && STORE="unknown"

            ${pkgs.curl}/bin/curl -sS --unix-socket ${influxdbSocket} \
              -XPOST "http://127.0.0.1/write?db=telegraf" \
              --data-binary "nixos_rebuild,action=$ACTION store=\"$STORE\",rev=\"${toString util.gitRev}\",value=1"
          '';
        };

        nextcloud-setup = lib.mkIf cfg.scrapers.cloud {
          serviceConfig.EnvironmentFile = lib.mkAfter [ config.age.secrets.${secret "cloudToken"}.path ];
          postStart = lib.mkAfter ''
            nextcloud-occ config:app:set serverinfo token --value="$TELEGRAF_TOKEN"
          '';
        };

        alloy = lib.mkIf cfg.loki {
          serviceConfig = util.systemd.base // {
            IPAddressAllow = "localhost";
            MemoryDenyWriteExecute = false;
            PrivateNetwork = false;
            RestrictAddressFamilies = "AF_INET";
          };
        };

        loki = lib.mkIf cfg.loki {
          serviceConfig = util.systemd.base // {
            IPAddressAllow = "localhost";
            PrivateNetwork = false;
            RestrictAddressFamilies = "AF_INET";
          };
        };
      };

      tmpfiles.rules = lib.optional (
        cfg.loki && config.celo.modules.core.impermanence.enable
      ) "d /var/lib/private 0700 root root - -";
    };

    system.activationScripts.saveNixosAction.text = ''
      if [[ "$NIXOS_ACTION" != "dry-activate" ]]; then
        mkdir -p /run/nixos-rebuild
        mv /run/nixos-rebuild/action /run/nixos-rebuild/action-old &> /dev/null || true
        echo "''${NIXOS_ACTION:-boot}	$systemConfig" > /run/nixos-rebuild/action
      fi
    '';

    environment = {
      persistence = util.withImpermanence config {
        global.directories =
          let
            influxdb = config.services.influxdb;
            loki = config.services.loki;
          in
          [
            {
              directory = influxdb.dataDir;
              user = influxdb.user;
              group = influxdb.group;
              mode = "0755";
            }
          ]
          ++ (lib.optional cfg.loki {
            directory = loki.dataDir;
            user = loki.user;
            group = loki.group;
            mode = "0700";
          })
          ++ (lib.optional cfg.loki {
            directory = "/var/lib/private/alloy";
            user = "nobody";
            group = "nogroup";
            mode = "0755";
          });
      };

      etc."grafana-dashboards/overview.json" =
        if cfg.scrapers.wifidog && cfg.loki then
          {
            source = ./overview.json;
          }
        else
          let
            raw = builtins.fromJSON (builtins.readFile ./overview.json);
            remove = {
              layout =
                names: prev:
                util.mapDeep prev [ "spec" "layout" "spec" "tabs" ] (
                  map (
                    tab:
                    if tab.spec.title == "Resources" then
                      (util.mapDeep tab [ "spec" "layout" "spec" "items" ] (
                        builtins.filter (item: (builtins.any (n: n == item.spec.element.name) names))
                      ))
                    else
                      tab
                  )
                );
              element =
                names: prev: util.mapDeep prev [ "spec" "elements" ] (elements: removeAttrs elements names);
            };
            panel = {
              wifidog = [
                "panel-5"
              ];
              loki = [
                "panel-8"
                "panel-9"
                "panel-10"
              ];
            };
            filter = {
              wifidog =
                prev:
                if cfg.scrapers.wifidog then
                  prev
                else
                  lib.pipe prev [
                    (remove.layout panel.wifidog)
                    (remove.element panel.wifidog)
                  ];

              loki =
                prev:
                if cfg.loki then
                  prev
                else
                  lib.pipe prev [
                    (remove.layout panel.loki)
                    (remove.element panel.loki)
                    (prev: util.mapDeep prev [ "spec" "layout" ] (builtins.head prev.spec.layout.spec.tabs).spec.layout)
                  ];
            };
          in
          {
            text = lib.pipe raw [
              filter.wifidog
              filter.loki
              builtins.toJSON
            ];
          };
    };
  };
}
