{
  description = "Jason's NixOS Flake & Dotfiles Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Pinned for fcitx5-mozc: newer Qt uic rejects mozc's "::mozc::" class names.
    # Remove once nixos-unstable builds fcitx5-mozc again.
    nixpkgs-mozc.url = "github:nixos/nixpkgs/55bfb4d7437bd4e09ab7cba58a43bd68eb310044";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
    homeConfigurations = {
      jason = home-manager.lib.homeManagerConfiguration {
	inherit pkgs;
        modules = [
          ./home.nix
        ];
       };
     };
  };
}
