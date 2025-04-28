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
  config = lib.mkIf cfg.enable (
    util.mkPath path {
      usersDirectory = "Users";
      extraGroups = "staff";
    }
  );
}
