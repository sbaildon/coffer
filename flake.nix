{
  description = "Coffer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/fc8835d44a356d64953cb31f1b086fab1e25bb5b";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pandoc-bin = import ./flakes/pandoc-bin.nix { inherit pkgs system; };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        # nix develop
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/darwin/apple-sdk/frameworks.nix
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.python314
            pandoc-bin
            pkgs.erofs-utils
            pkgs.socat
            pkgs.coreutils
          ];
        };

        apps.python = {
          type = "app";
          program = "${pkgs.python315}/bin/python3";
        };
      }
    );
}
