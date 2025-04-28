path:
{
  lib,
  config,
  util,
  options,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkPath path {
    motd = options.users.motd;
  };

  config = lib.mkIf cfg.enable (
    (util.mkPath path {
      usersDirectory = "home";
      extraGroups = "wheel";
    })
    // {
      users = {
        motd = cfg.motd;
      };
    }
  );
}
