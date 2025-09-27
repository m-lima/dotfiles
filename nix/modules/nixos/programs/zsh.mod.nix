path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  home = config.celo.modules.core.home;
  ui = config.celo.modules.programs.ui;
in
{
  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        # This is overriden in the default configuration
        enableLsColors = false;
        shellAliases =
          if ui.hyprland.enable || ui.kde.enable then
            {
              cpwd = ''echo -n "$PWD" | ${pkgs.wl-clipboard}/bin/wl-copy'';
              ppwd = ''cd $(${pkgs.wl-clipboard}/bin/wl-paste)'';
            }
          else
            {
              cpwd = ''echo -n "$PWD" > /tmp/cpwd'';
              ppwd = ''cd $(cat /tmp/cpwd)'';
            };
      };
    };

    users.defaultUserShell = pkgs.zsh;

    environment.persistence = util.withImpermanence config {
      # Only home-manager sets this path
      home = lib.mkIf home.enable {
        directories = [
          ".local/share/zsh"
        ];
      };
    };
  };
}
