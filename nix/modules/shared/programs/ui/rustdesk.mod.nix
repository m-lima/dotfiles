path:
{
  config,
  util,
  pkgs,
  ...
}:
{
  options = util.mkOptionsEnable path;
}
