path:
{
  lib,
  config,
  util,
  pkgs,
  rootDir,
  ...
}:
let
  celo = config.celo.modules;
  cfg = util.getOptions path config;
  lsps = {
    cpp = {
      pkg = [ pkgs.clang-tools ];
      setup = "require('config.lspconfig.servers.cpp')";
      dependencies = [ ];
    };
    go = {
      pkg = [
        pkgs.gopls
        pkgs.gofumpt
        pkgs.golangci-lint
        pkgs.golangci-lint-langserver
      ];
      setup = "require('config.lspconfig.servers.go')";
      dependencies = [ ];
    };
    js = {
      pkg = [
        pkgs.typescript-language-server
        pkgs.vscode-langservers-extracted
        pkgs.biome
      ];
      setup = "require('config.lspconfig.servers.js').setup()";
      dependencies = [ ];
    };
    lua = {
      pkg = [ pkgs.lua-language-server ];
      setup = "require('config.lspconfig.servers.lua')";
      dependencies = [ ];
    };
    metals = {
      pkg = [ pkgs.metals ];
      setup = "require('config.metals')";
      dependencies = [
        pkgs.vimPlugins.nvim-metals
      ];
    };
    nix = {
      pkg = [
        pkgs.nil
        pkgs.nixfmt
      ];
      setup = "require('config.lspconfig.servers.nix')";
      dependencies = [ ];
    };
    python = {
      pkg = [ pkgs.pyright ];
      setup = "require('config.lspconfig.servers.python')";
      dependencies = [ ];
    };
    rust = {
      pkg = [ pkgs.rust-analyzer ];
      setup = "require('config.lspconfig.servers.rust')";
      dependencies = [ ];
    };
    zig = {
      pkg = [ pkgs.zls ];
      setup = "require('config.lspconfig.servers.zig')";
      dependencies = [ ];
    };
  };
in
{
  options = util.mkOptions path {
    lsps = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames lsps));
      description = ''
        A list of LSP names to install. Check the `pkgs` for available names.
      '';
      default = [
        "cpp"
        "go"
        "js"
        "lua"
        "nix"
        "python"
        "rust"
        "zig"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.neovim ];

    environment.etc = {
      "xdg/nvim/sysinit.vim".text =
        ""
        + builtins.readFile /${rootDir}/../vim/config/base/options.vim
        + builtins.readFile /${rootDir}/../vim/config/nvim/options.vim
        + builtins.readFile /${rootDir}/../vim/config/base/mapping.vim
        + builtins.readFile /${rootDir}/../vim/config/nvim/mapping.vim;
      "xdg/nvim/colors/simpalt.vim".source = /${rootDir}/../vim/simpalt.vim;
    };

    home-manager = util.withHome config {
      programs = {
        neovim = {
          enable = true;
          package = pkgs.neovim-unwrapped;

          withRuby = false;
          withPerl = false;
          withNodeJs = false;
          withPython3 = false;

          plugins = [
            pkgs.vimPlugins.vim-repeat
            pkgs.vimPlugins.plenary-nvim
            pkgs.vimPlugins.nvim-web-devicons
            pkgs.vimPlugins.nui-nvim
            pkgs.vimPlugins.vim-surround
            pkgs.vimPlugins.comment-nvim
            pkgs.vimPlugins.ReplaceWithRegister
            pkgs.vimPlugins.lightspeed-nvim
            pkgs.vimPlugins.nvim-treesitter-textobjects
            pkgs.vimPlugins.lualine-nvim
            pkgs.vimPlugins.vim-fugitive
            pkgs.vimPlugins.gitsigns-nvim
            pkgs.vimPlugins.telescope-nvim
            pkgs.vimPlugins.neo-tree-nvim
            # project-nvim
            pkgs.vimPlugins.telescope-fzf-native-nvim
            pkgs.vimPlugins.telescope-ui-select-nvim
            pkgs.vimPlugins.telescope-dap-nvim
            pkgs.vimPlugins.nvim-treesitter.withAllGrammars
            pkgs.vimPlugins.nvim-lspconfig
            # mason stuff
            # none-ls
            pkgs.vimPlugins.nvim-dap
            pkgs.vimPlugins.nvim-nio
            pkgs.vimPlugins.nvim-dap-ui
            pkgs.vimPlugins.nvim-cmp
            pkgs.vimPlugins.cmp-nvim-lsp
            pkgs.vimPlugins.cmp-nvim-lsp-signature-help
            pkgs.vimPlugins.cmp-buffer
            pkgs.vimPlugins.cmp-path
            pkgs.vimPlugins.cmp-cmdline
            pkgs.vimPlugins.cmp-tmux
            pkgs.vimPlugins.luasnip
            pkgs.vimPlugins.cmp_luasnip
            # vim-todo-lists
            # vsession
            pkgs.vimPlugins.toggleterm-nvim
            pkgs.vimPlugins.undotree
            pkgs.vimPlugins.render-markdown-nvim
            pkgs.vimPlugins.iron-nvim
          ]
          ++ lib.flatten (map (l: lsps.${l}.dependencies) cfg.lsps);
          extraPackages = lib.flatten (map (l: lsps.${l}.pkg) cfg.lsps);

          initLua = builtins.concatStringsSep "\n" [
            ''
              require('config.cmp')
              require('config.comment')
              require('config.dap')
              require('config.dap.ui')
              require('config.fugitive')
              require('config.gitsigns')
              require('config.iron')
              require('config.lightspeed')
              require('config.lspconfig')
              require('config.lua_out')
              require('config.lualine')
              require('config.neo_tree')
              require('config.telescope')
              require('config.toggleterm')
              require('config.treesitter.highlight')
              require('config.treesitter.none')
              require('config.undotree')
              require('config.render_markdown')

              -- Personal
              require('plugin.breadcrumbs')
              require('plugin.buffer_stack')
              require('plugin.dupe_comment')
              require('plugin.overlength')
            ''
            (lib.strings.concatMapStringsSep "\n" (l: lsps.${l}.setup) cfg.lsps)
            (builtins.readFile /${rootDir}/../vim/config/nvim/filetypes.lua)
          ];
        };
      };

      xdg.configFile = {
        "nvim/lua".source = /${rootDir}/../vim/config/nvim/lua;
      };
    };

    programs = lib.mkIf celo.programs.zsh.enable {
      zsh.interactiveShellInit = builtins.readFile /${rootDir}/../zsh/config/programs/nvim.zsh;
    };
  };
}
