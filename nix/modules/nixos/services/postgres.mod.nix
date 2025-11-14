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
  dataDir = config.services.postgresql.dataDir;
in
{
  options = util.mkOptions path {
    dataDir = lib.mkOption {
      type = lib.types.nullOr lib.types.singleLineStr;
      default = null;
      description = "Base path for Postgres";
    };

    subvolume = lib.mkEnableOption "btrfs subvolume for the data directory" // {
      default = true;
    };

    snap = lib.mkEnableOption "snapshots of the data directory" // {
      default = cfg.subvolume;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.snap -> cfg.subvolume;
        message = "To take snapshots, Postgres needs its own subvolume";
      }
    ];

    services = lib.mkIf (cfg.dataDir != null) {
      postgresql.dataDir = cfg.dataDir;
    };

    celo.modules = lib.mkIf cfg.subvolume {
      core.disko.extraMounts = {
        pg = {
          name = "@pg";
          mountpoint = dataDir;
        };
      };

      services.snapper.mounts = lib.mkIf cfg.snap (lib.mkAfter [ "pg" ]);
    };

    environment = lib.mkIf (!cfg.subvolume) {
      persistence = util.withImpermanence config {
        global.directories = [
          {
            directory = dataDir;
            group = "postgres";
            user = "postgres";
            mode = "0755";
          }
        ];
      };
    };
  };
}
