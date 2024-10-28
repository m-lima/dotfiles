{
  userName,
  homeDirectory,
  stateVersion,
}:
{
  pkgs,
  ...
}: {
  home.stateVersion = stateVersion;
  home.username = userName;
  home.homeDirectory = homeDirectory;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bat       # Configured in ZSH
    curl      # No-op
    delta     # Configured in Git
    fd        # Configured in ZSH
    fzf       # Defaults are OK
    git
    jq        # No-op
    neovim
    ripgrep   # Configured in ZSH
    tmux
    # Persist
    zoxide
    zsh
  ];

  # TODO: Fonts

  programs = {
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
      # TODO: nali-autosuggestions
      # TODO: simpalt
      # TODO: syntax highlight
      enable = true;
      initExtraFirst = with builtins; ''''
        + readFile ../../zsh/config/programs/bat.zsh
        + readFile ../../zsh/config/programs/fzf_fd.zsh
        + readFile ../../zsh/config/programs/rg.zsh
        + readFile ../../zsh/config/programs/zoxide.zsh;
    };
  };
}
