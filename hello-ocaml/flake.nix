# This tutorial assumes familiarity with the Nix expression
# language. See https://nixos.org/guides/nix-pills/basics-of-language.html
#
# Flakes are how we package things reproducibly in Nix.
# (there is a legacy way called "channels", but we do not speak
# of the dark days anymore).
#
# Every flake is an attribute set with a particular schema.
# You can see the schema here: https://nixos.wiki/wiki/Flakes#Flake_schema
{
  # The first attribute is "inputs". This is how we specify which other
  # flakes we want to consume.
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # Here we've asked for the nixos/nixpkgs github repository, on the nixos-unstable
  # branch. The Nix tooling will create a file flake.lock that locks a particular
  # git revision, making the flake fully reproducible.

  # The last attribute is outputs. This is a function from all the inputs to
  # an attirubte set of things the flake can build.
  outputs = {
    self,
    nixpkgs,
  }:
  # We want to be able to build our package on multiple arcitectures,
  # so we'll fold over a list of supported ones.
  # Note that the _evaluation_ of a nix expression is different from
  # the _execution_ of the build plan it produces. We can evaluate any
  # expression on any system that Nix is installed on, but we can only
  # execute build plans on our own architecture (unless we set up cross-compilation
  # which is super nice with Nix - see https://nix.dev/tutorials/cross-compilation).
  let
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
  in let
    packages =
      builtins.foldl'
      (
        acc: system:
        # We instantiate the nixpkgs library with our system.
        let
          pkgs = import nixpkgs {inherit system;};

          # Now lets finally write our package.
          hello = pkgs.stdenv.mkDerivation rec {
            name = "hello";
            # The source code is located in the same directory as this flake.
            src = ./.;
            # These are the dependencies we'll need to build our package
            buildInputs = with pkgs; [ocaml ocamlPackages.dune_2];
            # Now we tell Nix how to build our package. This script will be executed
            # in an environment that includes the files from src and the packages from buildInputs.
            # If we leave out a buildPhase, stdenv.mkDerivation defaults to 'make'
            buildPhase = ''
              dune build -p ${name}
            '';
            # We need to instruct Nix what to do with the results. stdenv.mkDerivation defaults to 'make install'
            installPhase = ''
              dune install --prefix $out ${name}
            '';
          };
        in
          # The flakes schema defines out output attribute called "packages" that describes
          # what packages the flake can build and on what system architectures.
          # We'll collect all the packages for all the architectures in our accumulator.
          acc // {${system}.hello = hello;}
      ) {}
      supportedSystems;
  in {inherit packages;};
  # Try examining the outputs of the flake with `nix flake show`
  #
  # Then try building the package with `nix build .#hello`
  # The `nix build` command will automatically infer your archecture
  # and build the package at the path `packages.${your architecture}.hello`
  #
  # This will produce a binary ./result/bin/hello
  # This a symlink to the nix store. Nix knows the hash of the build plan
  # that was used to produce the value, and will never have to rebuild
  # the package when executing a build plan with the same hash.
}
