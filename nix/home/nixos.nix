{
  stateVersion,
  userName,
  ...
}:
let
  homeDirectory = "/home/${userName}";
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${userName}" = (import ./home.nix) { inherit stateVersion userName homeDirectory; };
  };
}
