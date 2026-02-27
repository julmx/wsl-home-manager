{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    # Shell
    ./modules/shell/zsh.nix

    # CLI tools
    ./modules/cli/bat.nix
    ./modules/cli/fzf.nix
    ./modules/cli/git.nix
    ./modules/cli/lazygit.nix
    ./modules/cli/htop.nix
    ./modules/cli/btop.nix
    ./modules/cli/bottom.nix
    ./modules/cli/gh.nix

    # Editors
    ./modules/editors/nixvim.nix

    # Terminal multiplexer
    ./modules/tmux.nix

    # Utilities
    ./modules/eza.nix
    ./modules/zoxide.nix
    ./modules/tealdeer.nix
    ./modules/fastfetch.nix

    # File manager
    ./modules/yazi/default.nix
  ];

  home.username = "julmx";
  home.homeDirectory = "/home/julmx";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Search and file tools
    ripgrep
    fd
    ncdu
    duf
    unzip
    unrar
    wget

    # Fun / display
    onefetch
    cowsay
    lolcat
    mdcat

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    maple-mono.NF
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.home-manager.enable = true;
}
