{
  description = "Flake for NixOS installations";

  inputs = {
    # NixOs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Transient dependencies
    crane.url = "github:ipetkov/crane";
    systems.url = "github:nix-systems/default";

    # Dependencies
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        systems.follows = "systems";
      };
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = {
        systems.follows = "systems";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    sddm-sugar-candy-nix = {
      url = "gitlab:Zhaith-Izaliel/sddm-sugar-candy-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs = {
        # To avoid multiple instances
        nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    # Local dependencies
    simpalt = {
      url = "github:m-lima/simpalt-rs?tag=v0.3.6";
      inputs = {
        # To use 2024 edition
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
        crane.follows = "crane";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    ragenix = {
      url = "github:m-lima/ragenix?tag=v0.1.3";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        crane.follows = "crane";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      # nixpkgs-2405,
      # nixpkgs-unstable,
      nix-darwin,
      agenix,
      agenix-rekey,
      disko,
      flake-utils,
      home-manager,
      impermanence,
      ragenix,
      sddm-sugar-candy-nix,
      treefmt-nix,
      ...
    }@inputs:
    let
      util = import ./util { inherit (nixpkgs) lib; };
      mkHost = import ./hosts;
      nixosHost =
        {
          system,
          hostModules,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs util;
            # pkgs2405 = nixpkgs-2405.legacyPackages.${system};
            # pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
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
              ragenix.nixosModules.default
              sddm-sugar-candy-nix.nixosModules.default
            ];
        };
      darwinHost =
        {
          system,
          hostModules,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;

          specialArgs = {
            inherit inputs util;
          };

          modules =
            hostModules
            ++ util.loadModules ./modules
            ++ util.loadProfiles ./profiles
            ++ [
              agenix.nixosModules.default
              agenix-rekey.nixosModules.default
              home-manager.nixosModules.home-manager
              ragenix.nixosModules.default
            ];
        };
    in
    {
      nixosConfigurations = mkHost "nixos" nixosHost;
      # darwinConfigurations = mkHost darwinHost;

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations;
      };

      formatter = flake-utils.lib.eachDefaultSystemPassThrough (system: {
        ${system} =
          (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
            projectRootFile = "flake.nix";
            programs = {
              mdformat.enable = true;
              nixfmt.enable = true;
              shfmt.enable = true;
            };
            settings = {
              formatter = {
                shfmt.options = [ "-ci" ];
              };
              excludes = [
                "*.age"
                "*.jpg"
                "*.lock"
                "*.pub"
              ];
            };
          }).config.build.wrapper;
      });
    };
}
