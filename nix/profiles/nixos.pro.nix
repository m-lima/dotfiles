{
  core = {
    agenix = {
      enable = true;
      identityPath = "/persist/etc/ssh/ssh_host_ed25519_key";
    };
    disko.enable = true;
    home.enable = true;
    impermanence = {
      enable = true;
      wipe.enable = true;
    };
    nix.enable = true;
    system.enable = true;
    user.enable = true;
  };
  services = {
    ssh.enable = true;
  };
}
