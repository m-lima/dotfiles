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
  host = config.celo.host.id;
in
{
  options = util.mkOptions path {
    hostName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "Host name";
      default = host;
      example = "coal";
    };
    timeZone = lib.mkOption {
      description = "TimeZone to use";
      example = "Europe/Amsterdam";
      default = null;
      type = lib.types.nullOr lib.types.nonEmptyStr;
    };
    stateVersion = lib.mkOption {
      description = "See https://mynixos.com/nixpkgs/option/system.stateVersion";
      example = "24.11";
      type = lib.types.nonEmptyStr;
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable all firmware, regardless of license
    hardware.enableAllFirmware = true;

    boot = {
      # Use the latest linux packages
      # Update by `nix-channel --update` or `nixos-rebuild boot --upgrade`
      kernelPackages = pkgs.linuxPackages_latest;

      # Use the systemd-boot EFI boot loader.
      loader =
        if config.celo.modules.core.disko.legacy then
          {
            grub.enable = true;
          }
        else
          {
            systemd-boot = {
              enable = true;
              configurationLimit = 10;
            };
            efi.canTouchEfiVariables = true;
          };
    };

    # Define the hostname
    networking.hostName = cfg.hostName;

    # Set the time zone.
    time.timeZone = cfg.timeZone;

    # Select internationalization properties.
    i18n.defaultLocale = "en_US.UTF-8";

    age.secrets = {
      ${util.mkSecretPath path host} = {
        rekeyFile = ./_secrets/${host}/password.age;
      };
    };

    users = {
      mutableUsers = false;
      users = {
        root = {
          hashedPasswordFile = config.age.secrets.${util.mkSecretPath path host}.path;
        };
      };
    };

    system.stateVersion = cfg.stateVersion;
  };
}
