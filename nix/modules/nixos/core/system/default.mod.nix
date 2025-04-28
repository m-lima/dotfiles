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
  options = util.mkPath path {
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
  };
}
