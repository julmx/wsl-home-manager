{host, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = host.gitName;
        email = host.gitEmail;
      };
      push.default = "simple";
      init.defaultBranch = "main";
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
