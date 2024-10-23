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

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
  ];

  programs = {
    # git = {
    #   enable = true;
    # };
    zsh = {
      enable = true;
      histSize = 100000;
      enableLsColors = false;
      shellAliases = {};
      interactiveShellInit = ''
## colors.zsh
# Colors for ls
export LSCOLORS='Gxfxcxdxbxagafxbabacad'
export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=30;46:cd=30;45:su=0;41:sg=30;41:tw=30;42:ow=30;43'

# Match the completion colors to LS_COLORS
zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

# Nicer colors for the `kill` completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

## completion.zsh
# Do not autoselect the first completion entry
unsetopt menu_complete

# Disable start/stop flow control characters in the editor
unsetopt flowcontrol

# Show completion menu on successive tab press
setopt auto_menu

# Set the completion ahead of the cursor
setopt complete_in_word

# Don't do partial completions, always do the full completion
setopt always_to_end

# Make completions case- and hyphen-insensitive
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'

# Complete '.' and '..'
zstyle ':completion:*' special-dirs true

# Start the selection unconditionally
zstyle ':completion:*:*:*:*:*' menu select

zstyle ':completion:*:*:*:*:processes' command 'ps -u '"''${USERNAME}"' -o pid,user,comm -w -w'

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' '_*'

# Override the ignores in single case scenario
zstyle '*' single-ignored show

# Disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Enable autocompletion
autoload -U compinit && compinit

# Load bash completions
autoload -U +X bashcompinit && bashcompinit

# # TODO: Enable this?
# zstyle ':completion:*' use-cache yes
# # TODO: Make this persistent?
# zstyle ':completion:*' cache-path /Users/celo/.zgen/robbyrussell/oh-my-zsh-master/cache

## history.zsh
HISTSIZE=100000
SAVEHIST=100000

# Record timestamp of command in HISTFILE
setopt extended_history

# Delete duplicates first when size is reached
setopt hist_expire_dups_first

# Ignore duplicates
setopt hist_ignore_all_dups

# Don't save to history if starting with a space
setopt hist_ignore_space

# When reloading from history, don't just run it, but update the buffer
setopt hist_verify

# Share history across sessions
setopt share_history

## keys.zsh
# Enable vim editing of command
autoload edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

## misc.zsh
# Enable multiple streams: echo >file1 >file2
setopt multios

# Show long lint format job notifications
setopt long_list_jobs

# Recognize comments
setopt interactivecomments
      '';
    };
    # # TODO: Configure globally
    # neovim = {
    #   enable = true;
    #   defaultEditor = true;
    #   viAlias = true;
    # };
    # # TODO: Move to user
    # hyprland = {
    #   enable = true;
    # };
    # # TODO: Move to user
    # firefox = {
    #   enable = true;
    # };
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

  # home-manager = {
  #   users = {
  #     celo = {
  #       home.stateVersion = stateVersion;

  #       programs = {
  #         firefox = {
  #           enable = true;
  #         };
  #       };
  #     };
  #   };
  # };

  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
    };
  };

  system.stateVersion = stateVersion;
}
