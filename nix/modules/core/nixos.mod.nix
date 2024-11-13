path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getModuleOpion path config;
  userName = config.celo.userName;
in {
  options = util.mkModuleEnableOption path {
    hostName = lib.mkOption {
      description = "Host name";
      example = "silver";
      type = lib.types.nonEmptyStr;
    };

    timeZone = {
      description = "TimeZone to use";
      example = "Europe/Amsterdam";
      default = "Europe/Amsterdam";
      type = lib.types.nonEmptyStr;
    };
  };

  config = mkIf cfg.enable {
    # Enable all firmware, regardless of license
    hardware.enableAllFirmware = true;

    # Allow all poackages, regardless of license
    nixpkgs.config.allowUnfree = true;

    nix = {
      # Automatic garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
      };

      settings = {
        # Optimize storage
        auto-optimise-store = true;
        # Enable some experimental features
        experimental-features = [ "nix-command" "flakes" ];
      };
    };

    boot = {
      # Use the latest linux packages
      # Update by `nix-channel --update` or `nixos-rebuild boot --upgrade`
      kernelPackages = pkgs.linuxPackages_latest;

      # Use the systemd-boot EFI boot loader.
      loader = {
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

    users = {
      mutableUsers = false;
      users = {
        root = {
          hashedPasswordFile = "/persist/secrets/root.passwordFile";
        };
      };
    };

    system.stateVersion = "24.05";
  };
}
