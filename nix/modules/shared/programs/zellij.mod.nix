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
in
{
  options = util.mkOptionsEnable path;

  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      programs = {
        zellij = {
          enable = true;
          extraConfig = builtins.readFile /${rootDir}/../zellij/config.kdl;
          # layouts = {
          #   zjstatus = /${rootDir}/../zellij/layout.kdl;
          # };
        };
      };

      xdg.configFile = {
        "zellij/plugins/zjstatus.wasm".source = pkgs.zellijPlugins.zjstatus;
      };
    };
  };
}
