{
  stateVersion,
  userName,
  impermanence,
  ...
}:
let
  homeDirectory = "/home/${userName}";
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${userName}" = {
      imports = [
        impermanence.nixosModules.home-manager.impermanence
        ./home.nix
      ];
    };
  };
}
