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
  config = {
    environment.persistence."/persist" = lib.mkIf config.modules.impermanence.enable {
      users."${userName}" = {
        directories = [
          "code"
          ".local/share/zoxide"
        ];
        files = [
          ".zsh_history"
        ];
      };
    };

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
          homeDirectory = homeDirectory;
        };

        programs.home-manager.enable = true;
      };
    };
  };
}
