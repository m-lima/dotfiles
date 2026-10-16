path:
{
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
      home = {
        packages = [ pkgs.jetbrains.idea ];
        file = {
          ".ideavimrc".text =
            ""
            + (builtins.readFile /${rootDir}/../vim/config/base/options.vim)
            + (builtins.readFile /${rootDir}/../vim/config/base/mapping.vim)
            + (builtins.readFile /${rootDir}/../vim/config/idea/init.vim);
        };
      };
    };
  };
}
