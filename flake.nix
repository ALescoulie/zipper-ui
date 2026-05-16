{
  description = "My TCP implimentation and dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem
      [ "x86_64-linux" "aarch64-darwin" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          # Valgrind is not supported on macOS ARM
          valgrindSupported = system == "x86_64-linux";
        in
        {
          #packages.default = pkgs.stdenv.mkDerivation {
          #};


          devShells.default = pkgs.mkShell {
            buildInputs =
              [
                pkgs.ghc
                pkgs.cabal-install
              ];
          };
        });
}
