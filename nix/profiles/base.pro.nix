{
  core = {
    agenix.enable = true;
    disko.enable = true;
    impermanence = {
      enable = true;
      wipe.enable = true;
    };
    nixos.enable = true;
    user = {
      enable = true;
      home.enable = true;
    };
  };
  programs = {
    core = {
      curl.enable = true;
      git.enable = true;
      neovim.enable = true;
      zsh.enable = true;
    };
    bat.enable = true;
    delta.enable = true;
    fd.enable = true;
    fzf.enable = true;
    jq.enable = true;
    lazygit.enable = true;
    rage.enable = true;
    rg.enable = true;
    simpalt.enable = true;
    tmux.enable = true;
    xxd.enable = true;
    zoxide.enable = true;
  };
  services = {
    mdns.enable = true;
    ssh.enable = true;
  };
}
