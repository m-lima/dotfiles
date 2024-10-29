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
          persistence."/persist/${homeDirectory}" = lib.mkIf config.modules.impermanence.enable {
            allowOther = true;
            directories = [
              "code"
              ".local/share/zoxide"
            ];
            files = [
              ".zsh_history"
            ];
          };
        };

        programs.home-manager.enable = true;
      };
    };
  };
}
