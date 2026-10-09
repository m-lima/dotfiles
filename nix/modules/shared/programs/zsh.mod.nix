path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  xdg = util.xdg config;
  simpaltPkg = inputs.simpalt.lib.${pkgs.stdenv.hostPlatform.system}.zsh;
in
{
  options = util.mkOptions path {
    simpalt = {
      enable = lib.mkEnableOption "simpalt prompt" // {
        default = true;
      };
      toggleBinding = lib.mkOption {
        type = lib.types.singleLineStr;
        description = "Keybinding to toggle between long and short rendering";
        default = "^T";
      };
      symbol = lib.mkOption {
        description = "Symbol to identify the host in the prompt";
        example = "₵";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      zsh = {
        enable = true;
        # Will be loaded by our own scripts
        enableCompletion = false;
        interactiveShellInit = lib.mkBefore (
          ""
          + builtins.readFile /${rootDir}/../zsh/config/base/colors.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/completion.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/history.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/keys.zsh
          + builtins.readFile /${rootDir}/../zsh/config/base/misc.zsh
          + builtins.readFile /${rootDir}/../zsh/config/programs/ls.zsh
        );
      };
    };

    environment.shellAliases = lib.mkForce { };

    home-manager = util.withHome config {
      programs = {
        zsh = {
          enable = true;

          autosuggestion = {
            enable = true;
            highlight = "fg=blue";
          };

          initContent = lib.mkIf cfg.simpalt.enable (simpaltPkg {
            symbol = cfg.simpalt.symbol;
            toggleBinding = cfg.simpalt.toggleBinding;
          });

          # TODO: This is repeating stuff from the root to avoid the override from homemanager
          history = {
            ignoreAllDups = true;
            expireDuplicatesFirst = true;
            extended = true;
            path = "${xdg.abs "dataHome"}/zsh/history";
          };
        };
      };
    };
  };
}
