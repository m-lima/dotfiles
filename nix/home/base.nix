{
  userName,
  stateVersion,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users."${userName}" = import ./home.nix;
    users."${userName}".home.stateVersion = stateVersion;
    users."${userName}".programs.home-manager.enable = true;
  };
}
