{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };

  outputs = {self, ...} @ inputs:
    inputs.utils.lib.eachDefaultSystem (
      system: let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [inputs.gomod2nix.overlays.default];
        };
      in {
        packages = with pkgs; {
          default = callPackage ./package.nix {};
        };
        apps = {
          default = {
            type = "app";
            program = "${inputs.self.packages.${system}.default}/bin/rocm-topm";
          };
        };
        devShells = with pkgs; {
          default = mkShell {
            packages = [
              go
              gopls
              rocmPackages.rocm-smi
              inputs.gomod2nix.packages.${system}.default
            ];
          };
        };
      }
    );
}
