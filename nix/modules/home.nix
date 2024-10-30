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
          ../home
        ];
      };

      extraSpecialArgs = {
        inherit inputs userName homeDirectory stateVersion;
        sysconfig = config;
      };
    };

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
  };
}
