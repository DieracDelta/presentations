{
  description = "Typst Detexify";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typst.url = "github:typst/typst";
  };

  outputs = inputs@{ self, nixpkgs, utils, fenix, typst}:
    utils.lib.eachDefaultSystem (system:
    let
        fenixStable = with fenix.packages.${system}; combine [
            (stable.withComponents [ "cargo" "clippy" "rust-src" "rustc" "rustfmt" "llvm-tools-preview" ])
          ];
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            (self: super: {
              typst_bleeding_edge = typst.packages.${system}.default;
            })
          ];

        };
        in {
          defaultPackage = self.devShell.${system};
          devShell = pkgs.mkShell.override { } {
            shellHook = ''
              export CARGO_TARGET_DIR="$(git rev-parse --show-toplevel)/target_ditrs/nix_rustc";
            '';
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
            buildInputs =
              with pkgs; [
                pkg-config
                typst_bleeding_edge
                pandoc
                wasm-bindgen-cli
                fenixStable
                just
                cargo-expand
                typst-lsp
              ];
          };
    });
}
