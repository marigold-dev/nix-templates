{
  inputs = {
    nixpkgs.url = "github:anmonteiro/nix-overlays";
    nixpkgs.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.inputs.flake-utils.follows = "flake-utils";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-filter,
  }: let
    out = system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nix-filter.overlays.default];
      };
      inherit (pkgs) lib;
      myPkgs =
        pkgs.recurseIntoAttrs
        (import ./nix {
          inherit pkgs;
          nix-filter = nix-filter.lib;
          doCheck = true;
        })
        .native;
      myDrvs = lib.filterAttrs (_: value: lib.isDerivation value) myPkgs;
    in {
      devShell = pkgs.mkShell {
        inputsFrom = lib.attrValues myDrvs;
        buildInputs = with pkgs;
        with ocamlPackages; [
          ocaml-lsp
          ocamlformat
          odoc
          https://ligolang.org/?lang=cameligoocaml
          dune_3
          nixfmt
        ];
      };

      defaultPackage = myPkgs.service;

      defaultApp = {
        type = "app";
        program = "${myPkgs.service}/bin/service";
      };
    };
  in
    with flake-utils.lib;
      eachSystem (with system; [
        x86_64-linux
        aarch64-linux
        x86_64-darwin
        aarch64-darwin
      ])
      out;
}
