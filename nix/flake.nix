{
  description = "Flake for NixOS installations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simpalt = {
      url = "github:m-lima/simpalt-rs?tag=v0.3.5";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      agenix,
      agenix-rekey,
      disko,
      home-manager,
      flake-utils,
      impermanence,
      sddm-sugar-candy-nix,
      ...
    }@inputs:
    let
      util = import ./util { inherit (nixpkgs) lib; };
      mkHost =
        { system, hostModules }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs util;
            pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
          };

          modules =
            hostModules
            ++ util.loadModules ./modules
            ++ util.loadProfiles ./profiles
            ++ [
              agenix.nixosModules.default
              agenix-rekey.nixosModules.default
              disko.nixosModules.disko
              home-manager.nixosModules.home-manager
              impermanence.nixosModules.impermanence
              sddm-sugar-candy-nix.nixosModules.default
            ];
        };
    in
    {
      nixosConfigurations = (import ./hosts) mkHost;

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      formatter = flake-utils.lib.eachDefaultSystemPassThrough (system: {
        ${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
      });
    };
}
