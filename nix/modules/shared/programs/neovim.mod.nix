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
      pkg = [ pkgs.gopls ];
      setup = "require('config.lspconfig.servers.go')";
      dependencies = [ ];
    };
    js = {
      pkg = [
        pkgs.typescript-language-server
        pkgs.vscode-langservers-extracted
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
        pkgs.nixfmt-rfc-style
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
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ neovim ];

    environment.etc = {
      "xdg/nvim/init.vim".text =
        with builtins;
        ''''
        + readFile /${rootDir}/../vim/config/base/options.vim
        + readFile /${rootDir}/../vim/config/nvim/options.vim
        + readFile /${rootDir}/../vim/config/base/mapping.vim
        + readFile /${rootDir}/../vim/config/nvim/mapping.vim;
    };

    home-manager = util.withHome config {
      programs = {
        neovim = {
          enable = true;
          package = pkgs.neovim-unwrapped;
          plugins =
            with pkgs.vimPlugins;
            [
              vim-repeat
              plenary-nvim
              nvim-web-devicons
              nui-nvim
              vim-surround
              comment-nvim
              ReplaceWithRegister
              lightspeed-nvim
              nvim-treesitter-textobjects
              lualine-nvim
              fugitive
              gitsigns-nvim
              telescope-nvim
              neo-tree-nvim
              project-nvim
              telescope-fzf-native-nvim
              telescope-ui-select-nvim
              telescope-dap-nvim
              nvim-treesitter.withAllGrammars
              nvim-lspconfig
              # mason stuff
              # none-ls
              nvim-dap
              nvim-nio
              nvim-dap-ui
              nvim-cmp
              cmp-nvim-lsp
              cmp-nvim-lsp-signature-help
              cmp-buffer
              cmp-path
              cmp-cmdline
              cmp-tmux
              luasnip
              cmp_luasnip
              # vim-todo-lists
              # vsession
              toggleterm-nvim
              undotree
              render-markdown-nvim
              iron-nvim
            ]
            ++ lib.flatten (map (l: lsps.${l}.dependencies) cfg.lsps);
          extraPackages = lib.flatten (map (l: lsps.${l}.pkg) cfg.lsps);
        };
      };

      xdg.configFile = {
        "nvim/init.vim".text =
          with builtins;
          ''''
          + readFile /${rootDir}/../vim/config/base/options.vim
          + readFile /${rootDir}/../vim/config/nvim/options.vim
          + readFile /${rootDir}/../vim/config/base/mapping.vim
          + readFile /${rootDir}/../vim/config/nvim/mapping.vim
          + ''
            lua <<EOF
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
            require('config.project')
            require('config.telescope')
            require('config.toggleterm')
            require('config.treesitter.none')
            require('config.undotree')
            require('config.render_markdown')

            -- Personal
            require('plugin.breadcrumbs')
            require('plugin.buffer_stack')
            require('plugin.dupe_comment')
            require('plugin.overlength')
          ''
          + (lib.strings.concatMapStringsSep "\n" (l: lsps.${l}.setup) cfg.lsps)
          + readFile /${rootDir}/../vim/config/nvim/filetypes.lua
          + "\nEOF";
        "nvim/colors/simpalt.vim".source = /${rootDir}/../vim/simpalt.vim;
        "nvim/lua".source = /${rootDir}/../vim/config/nvim/lua;
      };
    };

    programs = lib.mkIf celo.programs.zsh.enable {
      zsh.interactiveShellInit = builtins.readFile /${rootDir}/../zsh/config/programs/nvim.zsh;
    };
  };
}
