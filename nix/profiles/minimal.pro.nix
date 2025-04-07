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
      nali = {
        enable = true;
        entries = {
          cd = "~/code";
          nx = "~/code/dotfiles/nix";
        };
      };
      neovim.enable = true;
      zsh.enable = true;
    };
  };
  services = {
    ssh.enable = true;
  };
}
