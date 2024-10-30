{
  stateVersion,
  userName,
  homeDirectory,
  ...
}: {
  imports = [
    ./base.nix
    ./ui.nix
  ];

  home = {
    stateVersion = stateVersion;
    username = userName;
    homeDirectory = homeDirectory;
  };

  programs.home-manager.enable = true;
}

