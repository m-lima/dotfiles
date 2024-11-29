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
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

    environment.persistence = util.withImpermanence config {
      global.directories = [ "/var/lib/bluetooth" ];
    };

    # TODO: Add bluedevil
    # TODO: Add waybar icon

    # home-manager = util.withHome config {
    #   services = {
    #     mpris-proxy.enable = true;
    #   };
    # };
  };
}
