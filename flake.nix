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
    # herdr (multiplexeur d'agents) — packagé par numtide.
    # Pas de `inputs.nixpkgs.follows` ici volontairement : sinon herdr est
    # recompilé depuis les sources (Rust + Zig). Sans follows, on garde le
    # nixpkgs épinglé par numtide et on bénéficie du cache cache.numtide.com.
    llm-agents.url = "github:numtide/llm-agents.nix";
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
