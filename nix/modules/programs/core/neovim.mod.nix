path:
{
  lib,
  config,
  util,
  pkgsUnstable,
  ...
}:
let
  cfg = util.getOptions path config;
  pkgs = pkgsUnstable;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ neovim ];

    environment.etc = {
      "xdg/nvim/init.vim".text =
        with builtins;
        ''''
        + readFile ../../../../vim/config/base/options.vim
        + readFile ../../../../vim/config/nvim/options.vim
        + readFile ../../../../vim/config/base/mapping.vim
        + readFile ../../../../vim/config/nvim/mapping.vim;
    };

    home-manager = util.withHome config {
      programs = {
        neovim = {
          enable = true;
          package = pkgs.neovim-unwrapped;
          plugins = with pkgs.vimPlugins; [
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
          ];
          extraPackages = with pkgs; [
            eslint
            gopls
            lua-language-server
            nil
            nixfmt-rfc-style
            pyright
            rust-analyzer
            typescript-language-server
          ];
        };
      };

      xdg.configFile = {
        "nvim/init.vim".text =
          with builtins;
          ''''
          + readFile ../../../../vim/config/base/options.vim
          + readFile ../../../../vim/config/nvim/options.vim
          + readFile ../../../../vim/config/base/mapping.vim
          + readFile ../../../../vim/config/nvim/mapping.vim
          + ''
            lua <<EOF
            require('config.cmp')
            require('config.comment')
            require('config.dap')
            require('config.dap.ui')
            require('config.fugitive')
            require('config.gitsigns')
            require('config.lightspeed')
            require('config.lspconfig')
            require('config.lspconfig.servers.go')
            require('config.lspconfig.servers.js').setup()
            require('config.lspconfig.servers.lua')
            require('config.lspconfig.servers.nil')
            require('config.lspconfig.servers.python')
            require('config.lspconfig.servers.rust')
            require('config.lua_out')
            require('config.lualine')
            require('config.neo_tree')
            require('config.project')
            require('config.telescope')
            require('config.toggleterm')
            require('config.treesitter.none')
            require('config.undotree')

            -- Personal
            require('plugin.breadcrumbs')
            require('plugin.buffer_stack')
            require('plugin.dupe_comment')
            require('plugin.overlength')
            EOF
          '';
        "nvim/colors/simpalt.vim".source = ../../../../vim/simpalt.vim;
        "nvim/lua".source = ../../../../vim/config/nvim/lua;
      };
    };
  };
}