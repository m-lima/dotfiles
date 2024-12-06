{
  description = "Flake for NixOS installations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # TODO: Repackage this better. Expose a module
    simpalt = {
      url = "github:m-lima/simpalt-rs";
      inputs.cargo2nix.follows = "cargo2nix";
    };

    # Transient
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix/release-0.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
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
