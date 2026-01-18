{
  description = "Flake for NixOS installations";

  inputs = {
    # NixOs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Transient dependencies
    crane.url = "github:ipetkov/crane";
    systems.url = "github:nix-systems/default";
    nix-template.url = "github:m-lima/nix-template";
    fenix = {
      url = "github:nix-community/fenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

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
      url = "github:nix-community/home-manager/release-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
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
    endgame = {
      url = "github:m-lima/endgame?ref=v0.1.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    ipifier = {
      url = "github:m-lima/ipifier?ref=v0.1.2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    passer = {
      url = "github:m-lima/passer?ref=v0.7.3";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    ragenix = {
      url = "github:m-lima/ragenix?ref=v0.2.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    simpalt = {
      url = "github:m-lima/simpalt-rs?ref=v0.3.10";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    # Skull at ./modules/shared/programs/skull/default.mod.nix
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-2405,
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
      hosts = import ./hosts;
      specialArgs = {
        inherit inputs util;
        rootDir = ./.;
        pkgs-2405 = nixpkgs-2405;
      };
      nixosHost =
        _: hostModules:
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;

          modules =
            hostModules
            ++ util.load.modules ./modules/shared
            ++ util.load.modules ./modules/nixos
            ++ util.load.profiles ./profiles/shared
            ++ util.load.profiles ./profiles/nixos
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
        _: hostModules:
        nix-darwin.lib.darwinSystem {
          inherit specialArgs;

          modules =
            hostModules
            ++ util.load.modules ./modules/shared
            ++ util.load.modules ./modules/darwin
            ++ util.load.profiles ./profiles/shared
            # TODO: Address this
            # ++ util.load.profiles ./profiles/darwin
            ++ [
              agenix.darwinModules.default
              agenix-rekey.nixosModules.default
              home-manager.darwinModules.home-manager
              ragenix.nixosModules.default
            ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs nixosHost (hosts.for "nixos");
      darwinConfigurations = builtins.mapAttrs darwinHost (hosts.for "darwin");

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.nixosConfigurations // self.darwinConfigurations;
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        treeFmtOpts = {
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
              "*.rage"
              "*.jpg"
              "*.lock"
              "*.pub"
            ];
          };
        };
        treeFmt = (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} treeFmtOpts).config.build;
      in
      {
        checks = {
          formatting = treeFmt.check self;
        };
        formatter = treeFmt.wrapper;
      }
    );

}
