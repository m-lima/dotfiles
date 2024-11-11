{
  description = "Flake for NixOS installations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simpalt = {
      url = "github:m-lima/simpalt-rs";
    };
  };

  outputs = {
    nixpkgs,
    disko,
    home-manager,
    impermanence,
    sddm-sugar-candy-nix,
    ...
  } @ inputs:
  let
    mkHost = {
      hostName,
      userName,
      system,
      timeZone ? "Europe/Amsterdam",
    }: nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs hostName userName timeZone;
            util = import ./util { lib = nixpkgs.lib; };
            stateVersion = "24.05";
          };
          system = system;
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            sddm-sugar-candy-nix.nixosModules.default
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
