{
  pkgs,
  inputs,
  ...
}: {
  # pi-coding-agent : agent CLI pour le coding (pi).
  # Sourced depuis nixos-unstable car pas encore présent dans la branche stable 26.05.
  home.packages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent
  ];
}
