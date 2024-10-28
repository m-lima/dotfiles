{
  userName,
  stateVersion,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${userName}" = {
      home.stateVersion = stateVersion;

      programs.home-manager.enable = true;
    };
  };
}
