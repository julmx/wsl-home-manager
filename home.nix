{ pkgs, local, ... }:

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
    ./modules/cli/herdr.nix

    # Editors
    ./modules/editors/neovim.nix

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

  home.username = local.username;
  home.homeDirectory = local.homeDirectory;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # Search and file tools
    ripgrep
    fd
    ast-grep # structural code search
    ncdu
    duf
    unzip
    unrar
    wget
    jq
    yq-go # YAML processor (mikefarah)
    just

    # Development
    nodejs_22
    pnpm
    pyright
    sqlite # sqlite3 CLI

    # Go
    go
    gopls
    delve # dlv debugger
    golangci-lint
    gofumpt # stricter gofmt
    gotools # goimports
    gomodifytags
    gotests
    impl

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

  # Cache binaire herdr : volontairement NON configuré ici.
  # Le daemon nix de ce système est multi-user avec `trusted-users = root` seul,
  # donc un substituter en config utilisateur (ce que gère home-manager) est
  # ignoré. Pour récupérer herdr pré-compilé au lieu de le builder (Rust + Zig),
  # ajouter au /etc/nix/nix.conf SYSTÈME (root) puis redémarrer le daemon :
  #   extra-substituters = https://cache.numtide.com
  #   extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=

  programs.home-manager.enable = true;
}
