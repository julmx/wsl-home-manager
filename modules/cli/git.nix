{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "julmx";
        email = "julmx@dev.local";
      };
      push.default = "simple";
      init.defaultBranch = "main";
      credential.helper = "cache --timeout=7200";
      merge.conflictStyle = "diff3";
      alias = {
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
  };
}
