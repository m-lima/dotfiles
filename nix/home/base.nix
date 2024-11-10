{
  pkgs,
  sysconfig,
  inputs,
  ...
}:
let
  cfg = sysconfig.modules.ui;
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
    inputs.simpalt.packages."${pkgs.system}".default
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
        + readFile ../../zsh/config/programs/bat.zsh
        + readFile ../../zsh/config/programs/fzf_fd.zsh
        + readFile ../../zsh/config/programs/rg.zsh
        + readFile ../../zsh/config/programs/zoxide.zsh;

      # Move to output of simpalt flake
      initExtra = with builtins; ''
        __simpalt_build_prompt() {
          (( ? != 0 )) && local has_error='-e'
          [ "''${jobstates}" ] && local has_jobs='-j'
          simpalt l -z $SIMPALT_MODE 'ɳ' $has_error $has_jobs
        }

        __simpalt_build_r_prompt() {
          if (( COLUMNS > 120 )); then
            simpalt r -z
          fi
        }

        simpalt_toggle_mode() {
          [ "$SIMPALT_MODE" ] && unset SIMPALT_MODE || SIMPALT_MODE='-l'
          zle reset-prompt
        }

        # Allow toggling. E.g.:
        # bindkey '^T' simpalt_toggle_mode
        zle -N simpalt_toggle_mode

        # Allow `eval` for the prompt
        setopt promptsubst
        PROMPT='$(__simpalt_build_prompt)'
        RPROMPT='$(__simpalt_build_r_prompt)'

        # Avoid penv from setting the PROMPT
        VIRTUAL_ENV_DISABLE_PROMPT=1

        # Simpalt toggle
        bindkey '^T' simpalt_toggle_mode'';
    };
  };

  home.file = {
    ".config/git/config" = with builtins; {
      text = ''''
        + readFile ../../git/config/gitconfig
        + readFile ../../git/config/delta;
    };
    ".config/git/ignore" = {
      source = ../../git/config/ignore;
    };
    ".config/tmux/tmux.conf" = {
      source = ../../tmux/base.conf;
    };
    ".config/tmux/script/edit.zsh" = {
      source = ../../tmux/script/edit.zsh;
      executable = true;
    };
    ".config/tmux/script/clear_scratches.sh" = {
      source = ../../tmux/script/clear_scratches.sh;
      executable = true;
    };
    ".config/tmux/script/condense_windows.sh" = {
      source = ../../tmux/script/condense_windows.sh;
      executable = true;
    };
    ".config/tmux/script/status_right.sh" = with builtins; {
      text = ''#!/usr/bin/env bash
        ''
        + readFile ../../tmux/script/status/simpalt.sh
        # TODO
        # + (if cfg.enable then readFile ../../tmux/script/status/spotify.sh else "")
        + readFile ../../tmux/script/status/time.sh;
      executable = true;
    };
  };
}

