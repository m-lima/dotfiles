{
  description = "Base NixOS flake for installations";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    }
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = {
    nixpkgs,
    ...
  } @ inputs: let {
    stateVersion = "24.05";
  } in {
    nixosConfigurations = {
        coal = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            stateVersion = stateVersion;
            hostName = "coal";
          };
          system = "x86_64-linux";
          modules = [
            impermanence.nixosModules.impermanence
            ./configuration.nix
          ];
        };
      };
    };
  };
}
