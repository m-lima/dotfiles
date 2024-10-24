{
  description = "Base NixOS flake for installations";


  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    impermanence,
    disko,
    ...
  } @ inputs:
  let
    mkHost = {
      hostName,
      userName,
      system,
    } : nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs hostName userName;
            stateVersion = "24.05";
          };
          system = system;
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            ./modules
            ./hosts/${hostName}
          ];
        };
  in {
    nixosConfigurations = {
      coal = mkHost {
        hostName = "coal";
        userName = "celo";
        system = "x86_64-linux";
      };
      utm = mkHost {
        hostName = "utm";
        userName = "celo";
        system = "aarch64-linux";
      };
    };
  };
}
