{
  description = "Configuration for MacOS and NixOS";

  nixConfig = {
    substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    darwin,
    home-manager,
    nixpkgs,
    disko,
    lix-module,
    ...
  } @ inputs: let
    inherit (self) outputs;
    user = "kershuen";
    linuxSystems = ["x86_64-linux" "aarch64-linux"];
    darwinSystems = ["aarch64-darwin" "x86_64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable home-manager modules you might want to export
    homeManagerModules = import ./modules/home-manager;
    # Reusable darwin modules
    darwinModules = import ./modules/darwin;

    darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
      system: let
        user = "kershuen";
      in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {inherit inputs outputs;};
          modules = [
            home-manager.darwinModules.home-manager
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
    );

    nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs;};
        modules = [
          disko.nixosModules.disko
          lix-module.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/nixos/home-manager.nix;
              backupFileExtension = "backup";
            };
          }
          ./hosts/nixos
        ];
      });
  };
}
