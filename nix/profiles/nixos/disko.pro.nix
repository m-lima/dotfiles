{
  core = {
    disko.enable = true;
    impermanence = {
      enable = true;
      wipe = {
        enable = true;
        retainRoot = 0;
      };
    };
  };
  services = {
    snapper.enable = true;
  };
}
