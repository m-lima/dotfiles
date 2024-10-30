{
  lib,
  pkgs,
  hostName,
  userName,
  stateVersion,
  timeZone,
  ...
}: {
  imports = [
    ./base
    ./ui
    ./disko.nix
    ./home.nix
    ./impermanence.nix
  ];

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
  networking.hostName = hostName;

  # Set the time zone.
  time.timeZone = timeZone;

  # Select internationalization properties.
  i18n.defaultLocale = "en_US.UTF-8";

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPasswordFile = "/persist/secrets/root.passwordFile";
      };
      ${userName} = {
        isNormalUser = true;
        hashedPasswordFile = "/persist/secrets/${userName}.passwordFile";
        extraGroups = [ "wheel" ];
      };
    };
  };

  # TODO: Does this need to be a variable
  system.stateVersion = stateVersion;
}
