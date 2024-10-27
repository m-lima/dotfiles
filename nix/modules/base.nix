# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  hostName,
  userName,
  stateVersion,
  timeZone ? "Europe/Amsterdam",
  ...
}: {
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
  time.timeZone = "Europe/Amsterdam";

  # Select internationalization properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # To search for available packages:
  # $ nix search nixpkgs wget
  environment.systemPackages = with pkgs; [
    curl
    neovim
    zsh
  ];

  # environment.systemPackages = with pkgs; [
  #   bat
  #   curl
  #   delta
  #   fd
  #   fzf
  #   git
  #   neovim
  #   ripgrep
  #   zoxide
  #   zsh
  # ];

  # # TODO: This is a smell.. Should go into HM
  # environment.etc = with builtins; {
  #   gitignore.text = readFile ../../git/config/ignore;
  #   gitconfig.text = ''
  #     [core]
  #     	excludesfile = /etc/gitignore
  #     ''
  #     + readFile ../../git/config/gitconfig
  #     + readFile ../../git/config/delta;
  # };

  # # TODO: Any guy here should go into HM
  # programs = {
  #   fzf = {
  #     keybindings = true;
  #     fuzzyCompletion = true;
  #   };
  #   # # TODO: Neovim!!
  #   # neovim = {
  #   # };
  #   # TODO: nali-autosuggestions
  #   # TODO: simpalt
  #   # TODO: syntax highlight
  #   zsh = {
  #     enable = true;
  #     histSize = 100000;
  #     enableLsColors = false;
  #     shellAliases = {};
  #     interactiveShellInit = with builtins; ''''
  #       + readFile ../../zsh/config/base/colors.zsh
  #       + readFile ../../zsh/config/base/completion.zsh
  #       + readFile ../../zsh/config/base/history.zsh
  #       + readFile ../../zsh/config/base/keys.zsh
  #       + readFile ../../zsh/config/base/misc.zsh
  #       + readFile ../../zsh/config/programs/bat.zsh
  #       + readFile ../../zsh/config/programs/fzf_fd.zsh
  #       + readFile ../../zsh/config/programs/git.zsh
  #       + readFile ../../zsh/config/programs/ls.zsh
  #       + readFile ../../zsh/config/programs/nvim.zsh
  #       + readFile ../../zsh/config/programs/rg.zsh
  #       + readFile ../../zsh/config/programs/zoxide.zsh;
  #   };
  # };

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      defaultEditor = true;
      configure = {
        customRC = with builtins; ''''
          + readFile ../../vim/config/options.vim
          + readFile ../../vim/config/mapping.vim;
      };
    };
    zsh = {
      enable = true;
      enableLsColors = false;
      shellAliases = {};
      interactiveShellInit = with builtins; ''''
        + readFile ../../zsh/config/base/colors.zsh
        + readFile ../../zsh/config/base/completion.zsh
        + readFile ../../zsh/config/base/history.zsh
        + readFile ../../zsh/config/base/keys.zsh
        + readFile ../../zsh/config/base/misc.zsh;
    };
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
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
