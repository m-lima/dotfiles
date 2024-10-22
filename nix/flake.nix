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
    stateVersion = "24.05";
    mkMachine = {
      hostModule,
      hostName,
      system
    } : nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          stateVersion = stateVersion;
          hostName = hostName;
        };
          system = system;
          modules = [
            impermanence.nixosModules.impermanence
            disko.nixosModules.disko
            hostModule
          ];
        }
  in {
    nixosConfigurations = {
      coal = mkHost {
        hostModule = ./hosts/coal;
        hostName = "coal";
        system = "x86_64-linux";
      };
      utm = mkHost {
        hostModule = ./hosts/utm;
        hostName = "utm";
        system = "aarch64-linux";
      };
    };
  };
}
