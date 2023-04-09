{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      ocaml = {
        path = ./ocaml;
        description = "OCaml development flake";
      };

      hello-ocaml = {
        path = ./hello-ocaml;
        description = "A first look at Nix flakes";
      };

      hello-ocaml-dream = {
        path = ./hello-ocaml-dream;
        description = "An extension of the hello-ocaml flake into a more full environment";
      };

      node-typescript-simple = {
        path = ./node-typescript-simple;
        description = "A NodeJS/TypeScript development flake";
      };
    };
  };
}
