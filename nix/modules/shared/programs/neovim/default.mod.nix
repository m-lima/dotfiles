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
  custom = {
    kotlin = {
      lsp = pkgs.callPackage ./kotlin/lsp.pkg.nix { };
      plugin = pkgs.callPackage ./kotlin/plugin.pkg.nix { };
    };
  };
  lsps = {
    cpp = {
      pkgs = [ pkgs.clang-tools ];
      setup = "require('config.lspconfig.servers.cpp')";
    };
    go = {
      pkgs = [
        pkgs.gopls
        pkgs.gofumpt
        pkgs.golangci-lint
        pkgs.golangci-lint-langserver
      ];
      setup = "require('config.lspconfig.servers.go')";
    };
    js = {
      pkgs = [
        pkgs.typescript-language-server
        pkgs.vscode-langservers-extracted
        pkgs.biome
      ];
      setup = "require('config.lspconfig.servers.js').setup()";
    };
    kotlin = {
      enable = false;
      pkgs = [ custom.kotlin.lsp ];
      plugins = [ custom.kotlin.plugin ];
      setup = "require('config.lspconfig.register').register('kotlin', require('kotlin').setup({ }))";
      extraArgs = [
        "--set"
        "KOTLIN_LSP_DIR"
        "${custom.kotlin.lsp}/share/kotlin-lsp"
      ];
    };
    lua = {
      pkgs = [ pkgs.lua-language-server ];
      setup = "require('config.lspconfig.servers.lua')";
    };
    metals = {
      enable = false;
      pkgs = [ pkgs.metals ];
      setup = "require('config.metals')";
      plugins = [ pkgs.vimPlugins.nvim-metals ];
    };
    nix = {
      pkgs = [
        pkgs.nil
        pkgs.nixfmt
      ];
      setup = "require('config.lspconfig.servers.nix')";
    };
    python = {
      pkgs = [ pkgs.pyright ];
      setup = "require('config.lspconfig.servers.python')";
    };
    rust = {
      pkgs = [ pkgs.rust-analyzer ];
      setup = "require('config.lspconfig.servers.rust')";
    };
    zig = {
      pkgs = [ pkgs.zls ];
      setup = "require('config.lspconfig.servers.zig')";
    };
  };
in
{
  options = util.mkOptions path {
    lsps = lib.mapAttrs (k: v: {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable LSP for ${k}";
        default = v.enable or true;
      };
      pkgs = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        description = "Required system packages";
        default = v.pkgs or [ ];
      };
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        description = "Required neovim plugins";
        default = v.plugins or [ ];
      };
      setup = lib.mkOption {
        type = lib.types.str;
        description = "Setup lua script for neovim";
        default = v.setup or "";
      };
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        description = "Extra args to send to neovim upon launch";
        default = v.extraArgs or [ ];
      };
    }) lsps;
  };

  config =
    let
      enabledLsps = lib.filterAttrs (_: v: v.enable) cfg.lsps;
    in
    lib.mkIf cfg.enable {
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

      home-manager = util.given.home config {
        programs = {
          neovim = {
            enable = true;
            package = pkgs.neovim-unwrapped;

            withRuby = false;
            withPerl = false;
            withNodeJs = false;
            withPython3 = false;

            extraWrapperArgs = lib.flatten (lib.mapAttrsToList (_: v: v.extraArgs) enabledLsps);

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
            ++ lib.flatten (lib.mapAttrsToList (_: v: v.plugins) enabledLsps);

            extraPackages = lib.flatten (lib.mapAttrsToList (_: v: v.pkgs) enabledLsps);

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
              (lib.strings.concatMapAttrsStringSep "\n" (_: v: v.setup) enabledLsps)
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
