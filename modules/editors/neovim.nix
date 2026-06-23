{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [inputs.nixvim.homeModules.nixvim];

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    # On garde `inputs.nixvim.inputs.nixpkgs.follows = "nixpkgs"` (un seul
    # nixpkgs partagé → réutilisation max du store). Définir explicitement
    # la source supprime l'avertissement « default value affected by follows ».
    nixpkgs.source = inputs.nixpkgs;

    extraPackages = with pkgs; [
      # Runtime tools
      ripgrep
      fd
      lazygit

      # LSP servers
      nil # Nix
      lua-language-server
      pyright
      ruff
      typescript-language-server
      vscode-langservers-extracted # HTML/CSS/JSON
      clang-tools

      # Formatters
      prettierd
      stylua
      shfmt

      # Runtimes
      python3
      nodejs

      # Go
      go
      gopls
      delve
      gofumpt
      gotools # goimports
      golangci-lint
    ];

    extraPlugins = [pkgs.vimPlugins.lazy-nvim];

    extraConfigLua = let
      plugins = with pkgs.vimPlugins; [
        # LazyVim core
        LazyVim
        blink-cmp
        bufferline-nvim
        conform-nvim
        dashboard-nvim
        dressing-nvim
        flash-nvim
        friendly-snippets
        gitsigns-nvim
        grug-far-nvim
        indent-blankline-nvim
        lazydev-nvim
        lualine-nvim
        luvit-meta
        neo-tree-nvim
        noice-nvim
        nui-nvim
        nvim-lint
        nvim-lspconfig
        nvim-snippets
        nvim-treesitter
        nvim-treesitter-textobjects
        nvim-ts-autotag
        persistence-nvim
        plenary-nvim
        snacks-nvim
        telescope-fzf-native-nvim
        telescope-nvim
        todo-comments-nvim
        tokyonight-nvim
        trouble-nvim
        ts-comments-nvim
        which-key-nvim

        # Aliases for plugins with different names
        {name = "catppuccin"; path = catppuccin-nvim;}
        {name = "mini.ai"; path = mini-nvim;}
        {name = "mini.icons"; path = mini-nvim;}
        {name = "mini.pairs"; path = mini-nvim;}
      ];
      mkEntryFromDrv = drv:
        if lib.isDerivation drv
        then {
          name = "${lib.getName drv}";
          path = drv;
        }
        else drv;
      lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
    in ''
      require("lazy").setup({
        defaults = {
          lazy = true,
        },
        dev = {
          path = "${lazyPath}",
          patterns = { "" },
          fallback = true,
        },
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          -- force enable telescope-fzf-native.nvim
          { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
          -- disable mason (use Nix extraPackages instead)
          { "mason-org/mason-lspconfig.nvim", enabled = false },
          { "mason-org/mason.nvim", enabled = false },
          -- python support
          { import = "lazyvim.plugins.extras.lang.python" },
          -- go support
          { import = "lazyvim.plugins.extras.lang.go" },
          -- put this line at the end of spec to clear ensure_installed
          { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end },
        },
      })
    '';
  };
}
