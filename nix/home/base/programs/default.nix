{
  pkgs,
  sysconfig,
  inputs,
  ...
}:
let
  cfg = sysconfig.modules.ui;
  simpalt = inputs.simpalt.packages."${pkgs.system}";
in {
  home.packages = with pkgs; [
    bat       # Configured in ZSH
    curl      # No-op
    delta     # Configured in Git
    fd        # Configured in ZSH
    fzf       # Done
    git       # Done
    gnupg
    jq        # No-op
    neovim
    openssh
    ripgrep   # Configured in ZSH
    tmux      # Done
    zoxide    # Done one level up
    zsh       # Done
    # GPG
    # skull
    simpalt.default
  ];

  programs = {
    fzf = {
      enable = true;
    };
    gpg = {
      enable = true;
      mutableKeys = false;
      mutableTrust = false;
    };
    # # TODO: Neovim!!
    # neovim = {
    # };
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
    zsh = {
      # TODO: This is repeating stuff from the root to avoid the override from homemanager
      history = {
        ignoreAllDups = true;
        expireDuplicatesFirst = true;
        extended = true;
      };
      # TODO: nali-autosuggestions
      # TODO: syntax highlight
      # TODO: Completion not working. E.g. git
      enable = true;
      initExtraFirst = with builtins; ''''
        + readFile ../../../../zsh/config/programs/bat.zsh
        + readFile ../../../../zsh/config/programs/fzf_fd.zsh
        + readFile ../../../../zsh/config/programs/rg.zsh
        + readFile ../../../../zsh/config/programs/zoxide.zsh;

      initExtra = simpalt.zsh { symbol = "ɳ"; toggleBinding = "^T"; };
    };
  };

  home.file = {
    ".config/git/config" = with builtins; {
      text = ''''
        + readFile ../../../../git/config/gitconfig
        # Colors are off
        + readFile ../../../../git/config/delta;
    };
    ".config/git/ignore" = {
      source = ../../../../git/config/ignore;
    };
    ".config/tmux/tmux.conf" = {
      source = ../../../../tmux/base.conf;
    };
    ".config/tmux/script/edit.zsh" = {
      source = ../../../../tmux/script/edit.zsh;
      executable = true;
    };
    ".config/tmux/script/clear_scratches.sh" = {
      source = ../../../../tmux/script/clear_scratches.sh;
      executable = true;
    };
    ".config/tmux/script/condense_windows.sh" = {
      source = ../../../../tmux/script/condense_windows.sh;
      executable = true;
    };
    ".config/tmux/script/status_right.sh" = with builtins; {
      text = ''#!/usr/bin/env bash
        ''
        + readFile ../../../../tmux/script/status/simpalt.sh
        # TODO
        # + (if cfg.enable then readFile ../../tmux/script/status/spotify.sh else "")
        + readFile ../../../../tmux/script/status/time.sh;
      executable = true;
    };
  };
}

