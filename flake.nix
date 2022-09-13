{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, zig-overlay, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ zig-overlay.overlays.default ];
      };
      lib = pkgs.lib;
    in rec {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.zigpkgs.master

          pkgs.python3Packages.livereload
          pkgs.entr

          pkgs.wabt

          pkgs.libsoundio
          pkgs.pkg-config
          pkgs.alsaLib
        ];
      };
  });
}
