{
  userName,
  ...
} @ inputs:
let
  homeDirectory = "/home/${userName}";
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${userName}" = import ./home.nix;
  };
}
