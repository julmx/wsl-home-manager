{
  pkgs,
  host,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  imports = [
    # Shell
    ./modules/shell/zsh.nix

    # CLI tools
    ./modules/cli/bat.nix
    ./modules/cli/fzf.nix
    ./modules/cli/git.nix
    ./modules/cli/lazygit.nix
    ./modules/cli/btop.nix
    ./modules/cli/gh.nix
    ./modules/cli/herdr.nix
    ./modules/cli/pi-coding-agent.nix

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

  home.username = host.username;
  home.homeDirectory = host.homeDirectory;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    # WSL integration — open files and URLs with Windows applications
    wsl-open

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
    nodejs
    pnpm
    pyright
    uv # python package/project manager
    sqlite # sqlite3 CLI

    # Rust
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    pkg-config

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
    "$HOME/go/bin"
    "$HOME/.local/share/pnpm"
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
