path:
{
  lib,
  config,
  util,
  ...
}:
{
  imports = util.nginx path config "minimal" {
    name = "ipe";
    locations = {
      "/" = {
        extraConfig = "default_type text/plain;";
        return = ''200 "$remote_addr"'';
      };
    };
  };

  options = util.mkOptionsEnable path;

  config = {
    assertions = [
      {
        assertion = config.services.nginx.enable;
        message = "Nginx needs to be enabled for ipe";
      }
    ];
  };
}
