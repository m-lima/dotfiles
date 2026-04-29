{
  description = "Flake for NixOS installations";

  inputs = {
    # NixOs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";

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
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        pre-commit-hooks.inputs.flake-compat.follows = "flake-compat";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
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
        flake-parts.follows = "flake-parts";
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
    elo = {
      url = "github:m-lima/elo?ref=nix-001";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    endgame = {
      url = "github:m-lima/endgame?ref=nix-003";
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
      url = "github:m-lima/ipifier?ref=nix-001";
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
      url = "github:m-lima/passer?ref=nix-001";
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
      url = "github:m-lima/ragenix?ref=nix-001";
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
      url = "github:m-lima/simpalt?ref=nix-001";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    skull = {
      url = "github:m-lima/skull?ref=nix-001";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
        helper.follows = "nix-template";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    wifidog = {
      url = "github:m-lima/wifidog?ref=nix-004";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        treefmt-nix.follows = "treefmt-nix";
        helper.follows = "nix-template";
        zig.inputs.flake-compat.follows = "flake-compat";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
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
      util = import ./util {
        inherit (nixpkgs) lib;
        flake = self;
      };
      hosts = import ./hosts;
      specialArgs = {
        inherit inputs util;
        rootDir = ./.;
        pkgs-unstable = nixpkgs-unstable;
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
              agenix-rekey.darwinModules.default
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
