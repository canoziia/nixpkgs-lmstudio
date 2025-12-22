{
  description = "LM Studio Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages.default = pkgs.callPackage ./package.nix { };

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          name = "lm-studio";
        };
      }
    );
}
