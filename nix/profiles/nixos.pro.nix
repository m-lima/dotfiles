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
  services = {
    ssh.enable = true;
  };
}
