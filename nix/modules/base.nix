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
    bat
    curl
    delta
    fd
    fzf
    git
    neovim
    ripgrep
    # TODO: Makes little sense to be global
    # TODO: Persist
    zoxide
    # TODO: Persist history
    zsh
  ];

  # TODO: This is a smell.. Should go into HM
  environment.etc = with builtins; {
    gitignore.text = readFile ../../git/config/ignore;
    gitconfig.text = ''
      [core]
      	excludesfile = /etc/gitignore
      ''
      + readFile ../../git/config/gitconfig
      + readFile ../../git/config/delta;
  };

  # TODO: Any guy here should go into HM
  programs = {
    fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };
    # # TODO: Neovim!!
    # neovim = {
    # };
    # TODO: nali-autosuggestions
    # TODO: simpalt
    # TODO: syntax highlight
    zsh = {
      enable = true;
      histSize = 100000;
      enableLsColors = false;
      shellAliases = {};
      interactiveShellInit = with builtins; ''''
        + readFile ../../zsh/config/base/colors.zsh
        + readFile ../../zsh/config/base/completion.zsh
        + readFile ../../zsh/config/base/history.zsh
        + readFile ../../zsh/config/base/keys.zsh
        + readFile ../../zsh/config/base/misc.zsh
        + readFile ../../zsh/config/programs/bat.zsh
        + readFile ../../zsh/config/programs/fzf_fd.zsh
        + readFile ../../zsh/config/programs/git.zsh
        + readFile ../../zsh/config/programs/ls.zsh
        + readFile ../../zsh/config/programs/nvim.zsh
        + readFile ../../zsh/config/programs/rg.zsh
        + readFile ../../zsh/config/programs/zoxide.zsh;
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        shell = pkgs.zsh;
        hashedPasswordFile = "/persist/secrets/root.passwordFile";
      };
      ${userName} = {
        shell = pkgs.zsh;
        isNormalUser = true;
        hashedPasswordFile = "/persist/secrets/${userName}.passwordFile";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEdF76DqhT29CS5oIfwUOd69XJfHDHwZ5A+jTVLIC7pqixpnPb5l3vJwsLvFjgjlj/tr5w0pK8U4JlAbdgeREykORIKRt48FSJ27msxBNtLPPpeWMK17uQamcVQgheaWdMHeXfB+XvrXPsVPK7/Qx5dRPyiPTo6z86khNONvSVJzEJFADsr/SnvW/ZfaUjVgIb53js1l2Up+QrVYlnfZVRAf9qEIHoL50dERQA5v1Jv/3SGnv/Dd9xzWm1vZ8JlTE5M0cXFxHwxjiQaqpgA9l5aby3AcF7lGaxvkmY5vOlqdsk+tcSebARRTrZni6rDtqhwbtmTpxeHzGL+7bmTzBfwKrFMZZhTa3rSSSU38LM2fbGCM30pNp4liJdKCo7ov+1nW6TUX6pC+CkNFBfI5zQHqblMb/x/EqNXGXNR6JhLGBQL0cZDZi5N61WJKwCs+8e1l6/Vw88M3/lA+7ywU+jmOVecEo4BuIg3LeUvsfIg7y5m2h21vlBQaA4GHBVixrdtY56g0nRNtngLU4cDb0H+ZnKFngZbU3YRoUI7xssWnjOTlwRmUs13onW4tUm2dP3K8Rls6Eyjr/VApRZ8TheHyRSLjh7t1IIHuIylW96Xe8IKg0nnHWd/rimcM0yWWUDYZra9HOjMCgzvofgGbHe7z1V4rNV/tZRoS5pSY9obw=="
        ];
      };
    };
  };

  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
    };

    # Enable local DNS resolution
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        addresses = true;
      };
    };
  };

  # TODO: Does this need to be a variable
  system.stateVersion = stateVersion;
}
