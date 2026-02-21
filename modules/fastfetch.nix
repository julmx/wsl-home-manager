{ ... }:
{
  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "35";
          output = "95";
        };
        separator = " ➜  ";
      };

      logo = {
        type = "small";
      };

      modules = [
        "break"
        {
          type = "os";
          key = "OS";
          keyColor = "31";
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = "31";
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = "31";
        }
        {
          type = "shell";
          key = " └  ";
          keyColor = "31";
        }
        "break"
        {
          type = "terminal";
          key = "Term ";
          keyColor = "32";
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = "32";
        }
        "break"
        {
          type = "host";
          format = "{5} {1} Type {2}";
          key = "PC   ";
          keyColor = "33";
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7}";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "memory";
          key = " ├  ";
          keyColor = "33";
        }
        {
          type = "disk";
          key = " └ 󰋊 ";
          keyColor = "33";
        }
        "break"
        {
          type = "uptime";
          key = "   Uptime   ";
        }
      ];
    };
  };
}
