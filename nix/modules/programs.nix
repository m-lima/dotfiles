{
  pkgs,
  ...
}: {
  # To search for available packages:
  # $ nix search nixpkgs wget
  environment.systemPackages = with pkgs; [
    curl
    neovim
    zsh
  ];

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

  users.defaultUserShell = pkgs.zsh;

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

}
