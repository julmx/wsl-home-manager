{ pkgs, inputs, ... }:
{
  # herdr : multiplexeur de terminal "agent-aware" (tmux pour les agents IA).
  # Packagé dans nixpkgs (pkgs/by-name/he/herdr), sourcé depuis nixos-unstable
  # car pas encore présent dans la branche stable 26.05.
  home.packages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.herdr
  ];
}
