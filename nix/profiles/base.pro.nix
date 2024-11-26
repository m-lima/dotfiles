{
  core = {
    disko.enable = true;
    nixos.enable = true;
    impermanence = {
      enable = true;
      wipe.enable = true;
    };
    user = {
      enable = true;
      home.enable = true;
    };
  };
  network = {
    mdns.enable = true;
  };
  programs = {
    bat.enable = true;
    curl.enable = true;
    delta.enable = true;
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    jq.enable = true;
    neovim.enable = true;
    rg.enable = true;
    simpalt.enable = true;
    tmux.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };
  services = {
    ssh.enable = true;
  };
}
