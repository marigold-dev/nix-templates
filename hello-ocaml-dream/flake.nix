# In ../hello-ocaml, we learned how to package
# a simple ocaml project with no external dependencies.
# In this next example, we'll extend our project with
# a library, Dream, as well as get a reproducible dev
# environment to allow us to hack on project easily.
# Lastly, we'll use nix bundlers to package our project
# in interesting ways.
{
  # Start off as usual by pulling nixpkgs
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # Dream isn't packaged in nixpkgs yet. But nixpkgs can be extended
  # with a system called overlays. Overlays are functions from a set of nixpkgs
  # to another a new set of nixpkgs.
  #
  # Anmonteiro and Ulrik have packaged many relevant OCaml libraries in the
  # following flake.
  inputs.ocaml-overlay.url = "github:anmonteiro/nix-overlays";
  # Finally, we'll reduce the boilerplate from our last example by pulling in
  # a commonly used utility library for flakes 
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, ocaml-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        # We'll apply our overlay when importing nixpkgs
        let
          pkgs = import nixpkgs { inherit system; overlays = [ ocaml-overlay.overlay ]; };
          # We did things the manual way before, but nixpkgs provides utilities
          # for working with dune packages.

          hello-server = with pkgs; (ocamlPackages.buildDunePackage {
            pname = "hello-server";
            version = "0.1";
            src = ./.;
            # dune and ocaml are automatically included in buildInputs
            buildInputs = with ocamlPackages; [ dream ];
          });
        in
        {
          packages = {
            inherit hello-server;
            # Any package called "default" is built when you run `nix build` with no
            # package specified.
            default = hello-server;
          };

          # By including an app, anyway can run your program with `nix run path/to/flake#hello-server
          apps = {
            hello-server= { type = "app"; program = "${hello-server}/bin/hello-server"; };
            # or with a default, even shorter: `nix run path/to/flake`
            default = self.apps.${system}.hello-server;
          };

          # Finally we come to the devshell. This defines an environment that can be built and entered
          # with the command `nix develop`. The purpose is to assemble all the tools you need to hack on
          # your package - build tools, linters, formatters, etc.
          devShell = pkgs.mkShell {
            # We can automatically carry over all the packages needed to build hello-server with 
            # the inputsFrom attribute;
            inputsFrom = [ hello-server];
            # We can also add dev-tools
            buildInputs = with pkgs; with ocamlPackages; [
              utop
              ocaml-lsp
              ocamlformat
              ocamlformat-rpc
            ];
          };
          # Try running `nix develop` to enter the dev environment and the following commands:
          # which ocamlfind
          # ocamlfind query dream
        }
      );
}
