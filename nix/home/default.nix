{
  stateVersion,
  userName,
  homeDirectory,
  ...
}:
{
  imports = [
    ./base
    ./ui
  ];

  home = {
    stateVersion = stateVersion;
    username = userName;
    homeDirectory = homeDirectory;
  };

  programs.home-manager.enable = true;
}
