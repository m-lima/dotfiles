{
  pkgs,
  lib,
  config,
  sysconfig ? import (<nixpkgs/nixos> {}).config,
  ...
}:
with lib;
let
  cfg = sysconfig.modules;
in {
  home.packages = with pkgs; [
    bat       # Configured in ZSH
    curl      # No-op
    delta     # Configured in Git
    fd        # Configured in ZSH
    fzf       # Done
    git
    jq        # No-op
    neovim
    ripgrep   # Configured in ZSH
    tmux
    zoxide    # Done one level up
    zsh
  ] ++ (
    if cfg.ui then [
      hyprland
    ] else []
  );

  # TODO: Fonts

  programs = {
    fzf = {
      enable = true;
    };
    git = {
      userName = "m-lima";
      userEmail = "m-lima@users.noreply.github.com";
      ignores = [
        "*~"
        ".DS_Store"
      ];
      delta = {
        enable = true;
      };
    };
    # # TODO: Neovim!!
    # neovim = {
    # };
    zsh = {
      # TODO: This is repeating stuff from the root to avoid the override from homemanager
      history = {
        ignoreAllDups = true;
        expireDuplicatesFirst = true;
        extended = true;
      };
      # TODO: nali-autosuggestions
      # TODO: simpalt
      # TODO: syntax highlight
      # TODO: Completion not working. E.g. git
      enable = true;
      initExtraFirst = with builtins; ''''
        + readFile ../../zsh/config/programs/bat.zsh
        + readFile ../../zsh/config/programs/fzf_fd.zsh
        + readFile ../../zsh/config/programs/rg.zsh
        + readFile ../../zsh/config/programs/zoxide.zsh;
    };
  };
}
