{
  description = "A collection of flake templates";

  outputs = { self }: {

    templates = {

      ocaml = {
        path = ./ocaml;
        description = "OCaml development flake";
      };
    };
  };
}