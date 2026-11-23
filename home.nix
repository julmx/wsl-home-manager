{
  pkgs,
  host,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  imports = [
    # Shell
    ./modules/shell/zsh.nix

    # CLI tools
    ./modules/cli/bat.nix
    ./modules/cli/codex.nix
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
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.proton-pass-cli

    # Development
    # Antigravity CLI (agy), depuis nixos-unstable.
    ((import inputs.nixpkgs-unstable {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "antigravity-cli";
    }).antigravity-cli)
    # Gitea CLI : recette de la PR Nixpkgs #586962 (87ac0e7e), à retirer quand gitea-cli sera empaqueté.
    (inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.callPackage ./packages/gitea-cli.nix {})
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
    "$HOME/.opencode/bin"
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
