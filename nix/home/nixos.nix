{
  stateVersion,
  userName,
  inputs,
  ...
}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${userName}" = {
      imports = [
        inputs.impermanence.nixosModules.home-manager.impermanence
        ./home.nix
      ];

      home = {
        stateVersion = stateVersion;
        username = userName;
        homeDirectory = "/home/${userName}";
      };

      programs.home-manager.enable = true;
    };
  };
}
