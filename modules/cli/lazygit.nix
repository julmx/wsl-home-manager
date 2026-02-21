{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      disableStartupPopups = true;
      notARepository = "quit";
      gui = {
        nerdFontsVersion = "3";
        showCommandLog = false;
        showRandomTip = false;
        border = "rounded";
        theme = {
          activeBorderColor = [ "#7aa2f7" "bold" ];
          inactiveBorderColor = [ "#565f89" ];
          searchingActiveBorderColor = [ "#7aa2f7" "bold" ];
          optionsTextColor = [ "#7aa2f7" ];
          selectedLineBgColor = [ "#2a2b3c" ];
          cherryPickedCommitFgColor = [ "#7aa2f7" ];
          cherryPickedCommitBgColor = [ "#bb9af7" ];
          markedBaseCommitFgColor = [ "#7aa2f7" ];
          markedBaseCommitBgColor = [ "#e0af68" ];
          unstagedChangesColor = [ "#db4b4b" ];
          defaultFgColor = [ "#c0caf5" ];
        };
      };
    };
  };
}
