{
  pkgs,
  inputs,
  ...
}: {
  # Codex CLI depuis nixos-unstable.
  home.packages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.codex
  ];
}
