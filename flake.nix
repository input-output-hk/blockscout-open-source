{
  description = "Blockscout";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/release-22.11?dir=lib";
    flake-parts.url = "github:hercules-ci/flake-parts/13dddfdc6701f05513fa77928ee90ad628b607c5";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    dream2nix = {
      url = "github:nix-community/dream2nix/12e45887b54ba4e8317fbdbcad1c30623abd32eb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake {inherit self;} {
      # Add additional systems to make output for here
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      perSystem = {inputs', self', pkgs, config, system, ...}: {
        packages = {
          default = config.packages.blockscout;
          blockscout = let
            initD2N = inputs.dream2nix.lib.init {
              inherit pkgs;
              config.projectRoot = ./.;
            };
            in pkgs.callPackage ./nix { inherit initD2N; src = self; };
        };
      };
    };
}
