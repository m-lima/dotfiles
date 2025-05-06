path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  config = lib.mkIf cfg.enable (
    util.mkPath path {
      usersDirectory = "Users";
    }
  );
}
