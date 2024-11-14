{
  pkgs,
  ...
}: {
  # To search for available packages:
  # $ nix search nixpkgs wget
  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    zsh
  ];

  environment.etc = {
    "xdg/nvim/init.vim".text = with builtins; ''''
        + readFile ../../../../vim/config/options.vim
        + readFile ../../../../vim/config/mapping.vim;
  };

  programs = {
    zsh = {
      enable = true;
      enableLsColors = false;
      shellAliases = {};
      interactiveShellInit = with builtins; ''''
        + readFile ../../../../zsh/config/base/colors.zsh
        + readFile ../../../../zsh/config/base/completion.zsh
        + readFile ../../../../zsh/config/base/history.zsh
        + readFile ../../../../zsh/config/base/keys.zsh
        + readFile ../../../../zsh/config/base/misc.zsh
        + readFile ../../../../zsh/config/programs/git.zsh
        + readFile ../../../../zsh/config/programs/ls.zsh
        + readFile ../../../../zsh/config/programs/nvim.zsh;
    };
  };

  users.defaultUserShell = pkgs.zsh;
}
