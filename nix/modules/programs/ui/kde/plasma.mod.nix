path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = config.celo.modules.programs.ui.kde;
in
{
  config = util.enforceHome path config cfg.enable {
    home-manager = {
      programs.plasma = {
        enable = true;

        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
        };

        hotkeys.commands."launch-terminal" = {
          name = "Lauch terminal";
          key = "Meta+T";
          command = "alacritty -e tmux";
        };

        kwin = {
          virtualDesktops = {
            number = 4;
            rows = 2;
          };
        };
      };

      # Need to use an import so that home-manager injects their lib
      imports = [
        (
          { lib, ... }:
          {
            home.activation = lib.mkIf (cfg.scale != null) {
              celo-kde-scale =
                let
                  payload = [
                    {
                      name = "outputs";
                      data = [ { scale = cfg.scale; } ];
                    }
                  ];
                in
                lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  run echo -n '${builtins.toJSON payload}' > ${
                    config.home-manager.users.${config.celo.modules.core.user.userName}.xdg.configHome
                  }/kwinoutputconfig.json.new
                '';
            };
          }
        )
      ];

    };
  };
}
