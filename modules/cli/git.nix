{ ... }:
{
  programs.git = {
    enable = true;
    userName = "julmx";
    userEmail = "julmx@dev.local";
    extraConfig = {
      push.default = "simple";
      init.defaultBranch = "main";
      credential.helper = "cache --timeout=7200";
      merge.conflictStyle = "diff3";
    };
    aliases = {
      br = "branch";
      co = "checkout";
      df = "diff";
      com = "commit";
      gs = "status";
      gp = "push";
      lg = "log --graph --oneline --decorate --all";
      st = "status -s";
    };
  };
}
