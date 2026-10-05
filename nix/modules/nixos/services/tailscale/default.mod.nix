path:
{
  lib,
  config,
  pkgs,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  loginServer = util.secret.rage.orElse config ./_secrets/loginServer.rage "";
in
{

  options = util.mkOptions path {
    exitNode = lib.mkOption {
      type = lib.types.bool;
      description = "Use this node as an exit node";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      tailscale = {
        enable = true;
        useRoutingFeatures = "both";
        extraUpFlags = [
          "--login-server ${loginServer}"
          "--accept-routes"
        ]
        ++ (lib.optional cfg.exitNode "--advertise-exit-node");
      };
    };

    systemd.services = lib.mkIf cfg.exitNode {
      tailscale-exit-node-opts = {
        description = "Tailscale exit node ethtool optimizations";

        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [
          iproute2
          ethtool
          coreutils
        ];

        script = ''
          NETDEV=$(ip -o route get 1.1.1.1 | cut -f 5 -d " ")

          if [ -z "$NETDEV" ]; then
            echo "Error: Could not determine default network device."
            exit 1
          fi

          echo "Applying UDP GRO forwarding optimizations to $NETDEV..."
          ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [
        {
          directory = "/var/lib/tailscale";
          mode = "0700";
        }
      ];
    };
  };
}
