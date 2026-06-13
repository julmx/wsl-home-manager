{ pkgs, inputs, ... }:
{
  # herdr : multiplexeur de terminal "agent-aware" (tmux pour les agents IA).
  # Packagé par numtide/llm-agents.nix (pas encore dans nixpkgs).
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
  ];
}
