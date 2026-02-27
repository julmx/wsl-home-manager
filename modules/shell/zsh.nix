{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "regexp" "root" "line"];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    sessionVariables = {
      UV_LINK_MODE = "copy";
    };

    envExtra = ''
      # Source nix-daemon for PATH setup (needed on WSL)
      if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      fi
    '';

    oh-my-zsh = {
      enable = true;
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./.; # points to modules/shell/ directory
        file = "p10k.zsh";
      }
    ];

    initContent = ''
      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word

      # Completion colors - Catppuccin Macchiato
      zstyle ':completion:*' list-colors "di=34" "ln=35" "so=32" "pi=33" "ex=31" "bd=34;46" "cd=34;43" "su=30;41" "sg=30;46" "tw=30;42" "ow=30;43"
      zstyle ':completion:*' menu select
      # Highlight selected completion item
      zstyle ':completion:*:*:*:*:descriptions' format '%F{#8aadf4}-- %d --%f'
      zstyle ':completion:*:messages' format '%F{#a6da95}-- %d --%f'
      zstyle ':completion:*:warnings' format '%F{#ed8796}-- no matches --%f'

      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi
    '';

    shellAliases = {
      sv = "sudo nvim";
      v = "nvim";
      c = "clear";
      cat = "bat";
      man = "batman";
      hms = "home-manager switch --flake ~/.config/home-manager";
    };
  };
}
