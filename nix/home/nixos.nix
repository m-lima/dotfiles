{
  userName,
  stateVersion,
  ...
} @ inputs:
let
  homeDirectory = "/home/${userName}";
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${userName}" = (import ./home.nix) { inherit userName stateVersion homeDirectory; } { inherit inputs; };
  };
}
