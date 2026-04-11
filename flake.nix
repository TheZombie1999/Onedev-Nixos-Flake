{
  description = "OneDev - Self-hosted Git Server with CI/CD";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";  # Change to aarch64-linux if needed
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.onedev = pkgs.callPackage ./onedev.nix { };
      nixosModules.onedev = import ./onedev-module.nix;
    };
}
