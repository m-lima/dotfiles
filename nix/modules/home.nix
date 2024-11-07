{
  stateVersion,
  userName,
  inputs,
  lib,
  config,
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
        ../home
      ];
    };

    extraSpecialArgs = {
      inherit inputs userName homeDirectory stateVersion;
      sysconfig = config;
    };
  };
}
