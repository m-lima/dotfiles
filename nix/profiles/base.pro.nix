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
    curl.enable = true;
    git.enable = true;
    neovim.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };
  services = {
    ssh.enable = true;
  };
}
