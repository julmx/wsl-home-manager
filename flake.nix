{
  description = "Home Manager configuration for WSL";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # herdr (multiplexeur d'agents) — désormais packagé dans nixpkgs
    # (pkgs/by-name/he/herdr), mais pas encore dans la branche stable 26.05.
    # Pin indépendant sur nixos-unstable pour récupérer le binaire pré-compilé
    # via cache.nixos.org (sinon recompilation Rust + Zig depuis les sources).
    # Pas de `inputs.nixpkgs.follows` : on garde un pin unstable séparé.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, home-manager, nixvim, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      local = import ./local.nix;
    in
    {
      homeConfigurations.${local.username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs local; };
        modules = [
          ./home.nix
        ];
      };
    };
}
