# nix-templates

Templates to quickly bootstrap a repo with `nix flakes`.

## OCaml

To get started in a existing repo:

`nix flake init --template github:ulrikstrid/nix-templates#ocaml`

To bootstrap a new repo run:

`nix flake new github:ulrikstrid/nix-templates#ocaml`

We're using yhe OCaml overlays [repo by @anmonteiro](https://github.com/anmonteiro/nix-overlays) to get some of the latest and greatest that hasn't yet made it to `nixpkgs`. There is also excellent support for static compilation.

In [./nix/generic.nix](./ocaml/nix/generic.nix) you'll specify how to build your project and the dependencies you have. Note that you need to change the name (currently set to `service`) to reflect the actual name of what you're building.
