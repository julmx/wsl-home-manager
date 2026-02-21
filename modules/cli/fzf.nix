{ ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--layout=reverse"
      "--prompt '/ '"
      "--preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}'"
      "--preview-window right:60%"
      "--color=bg+:#2a2b3c,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
      "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    ];
  };
}
