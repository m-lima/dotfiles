{
  stateVersion,
  userName,
  inputs,
  lib,
  util,
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
      inherit inputs util userName homeDirectory stateVersion;
      sysconfig = config;
    };
  };
}
