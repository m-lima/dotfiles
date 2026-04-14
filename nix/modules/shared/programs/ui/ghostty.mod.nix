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
  cfg = util.getOptions path config;
  prg = config.celo.modules.programs;
  hackCfg = prg.ui.fonts.hack;
  tmuxCfg = prg.tmux;
in
{
  options = util.mkOptions path {
    tmuxStart = lib.mkEnableOption "wrap the terminal in a tmux session by default" // {
      default = tmuxCfg.enable;
    };
    pkg = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.package;
      # TODO: Check that ghostty is available for darwin
      default = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    };
    exec = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.str;
    };
  };

  config = util.enforceHome path config cfg.enable {
    assertions = [
      {
        assertion = cfg.tmuxStart -> tmuxCfg.enable;
        message = "tmuxStart can only be used if tmux is present";
      }
    ];

    home-manager = {
      programs = {
        ghostty = {
          package = cfg.pkg;
          enable = true;
          enableZshIntegration = prg.zsh.enable;
          settings = {
            initial-command = lib.mkIf cfg.tmuxStart "direct:${pkgs.writeScript "start-tmux" ''
              #!${pkgs.bash}/bin/bash -l
              exec tmux new -A
            ''}";

            font-family = lib.mkIf hackCfg.enable [
              "Hack"
              "Hack Nerd Font Mono"
            ];
            font-size = 11;

            quit-after-last-window-closed = true;
            quit-after-last-window-closed-delay = "5m";

            macos-option-as-alt = "left";
            macos-titlebar-style = "hidden";

            window-padding-balance = true;
            window-width = 122;
            window-height = 44;

            cursor-style = "block";
            cursor-style-blink = false;
            shell-integration-features = "no-cursor";
            cursor-invert-fg-bg = true;

            background = "#262626";
            foreground = "#839496";
            palette = [
              "0=#333333"
              "1=#dc322f"
              "2=#44a400"
              "3=#edb300"
              "4=#268bd2"
              "5=#d33682"
              "6=#009aa1"
              "7=#eee8d5"
              "8=#3c3c3c"
              "9=#ff3a36"
              "10=#60e800"
              "11=#fff204"
              "12=#5bbbff"
              "13=#c66cc1"
              "14=#00cac9"
              "15=#fdf6e3"
            ];

            keybind = [
              "clear"
              "ctrl+escape>escape=csi:27;5;27~"

              # Selection
              "shift+arrow_up=adjust_selection:up"
              "shift+arrow_down=adjust_selection:down"
              "shift+arrow_left=adjust_selection:left"
              "shift+arrow_right=adjust_selection:right"
              "shift+page_up=adjust_selection:page_up"
              "shift+page_down=adjust_selection:page_down"
              "shift+home=adjust_selection:home"
              "shift+end=adjust_selection:end"

              # Clipboard
              "super+c=copy_to_clipboard"
              "super+v=paste_from_clipboard"

              # Font
              "super+-=decrease_font_size:1"
              "super+equal=increase_font_size:1"
              "super+ctrl+-=decrease_font_size:3"
              "super+ctrl+equal=increase_font_size:3"
              "super+0=reset_font_size"

              # Window
              "super+n=new_window"
              "super+enter=toggle_fullscreen"
              "super+alt+shift+w=close_all_windows"
              "super+shift+w=close_surface"

              # Splits
              "ctrl+escape>s=new_split:down"
              "ctrl+escape>v=new_split:right"
              "ctrl+escape>k=goto_split:up"
              "ctrl+escape>j=goto_split:down"
              "ctrl+escape>h=goto_split:left"
              "ctrl+escape>l=goto_split:right"
              "super+shift+enter=toggle_split_zoom"
              "ctrl+escape>ctrl+k=resize_split:up,10"
              "ctrl+escape>ctrl+j=resize_split:down,10"
              "ctrl+escape>ctrl+h=resize_split:left,10"
              "ctrl+escape>ctrl+l=resize_split:right,10"
              "ctrl+escape>equal=equalize_splits"

              # Tabs
              "ctrl+escape>1=goto_tab:1"
              "ctrl+escape>digit_1=goto_tab:1"
              "ctrl+escape>2=goto_tab:2"
              "ctrl+escape>digit_2=goto_tab:2"
              "ctrl+escape>3=goto_tab:3"
              "ctrl+escape>digit_3=goto_tab:3"
              "ctrl+escape>4=goto_tab:4"
              "ctrl+escape>digit_4=goto_tab:4"
              "ctrl+escape>5=goto_tab:5"
              "ctrl+escape>digit_5=goto_tab:5"
              "ctrl+escape>6=goto_tab:6"
              "ctrl+escape>digit_6=goto_tab:6"
              "ctrl+escape>7=goto_tab:7"
              "ctrl+escape>digit_7=goto_tab:7"
              "ctrl+escape>8=goto_tab:8"
              "ctrl+escape>digit_8=goto_tab:8"
              "ctrl+tab=next_tab"
              "ctrl+shift+tab=previous_tab"
              "ctrl+escape>0=last_tab"
              "ctrl+escape>digit_0=last_tab"
              "super+shift+t=new_tab"

              # Config
              "super+k=clear_screen"
              "super+alt+i=inspector:toggle"
              "super+shift+,=reload_config"
              "super+shift+p=toggle_command_palette"

              # Prompt
              "super+arrow_down=jump_to_prompt:1"
              "super+arrow_up=jump_to_prompt:-1"

              # Search
              "super+f=start_search"
              "ctrl+shift+n=navigate_search:next"
              "ctrl+shift+p=navigate_search:previous"

              # Undo
              "super+z=undo"
              "super+shift+z=redo"

              # Scroll
              "super+shift+home=scroll_to_top"
              "super+shift+end=scroll_to_bottom"
              "super+shift+page_down=scroll_page_down"
              "super+shift+page_up=scroll_page_up"
              "super+j=scroll_to_selection"

              # Screen
              "super+shift+ctrl+c=write_screen_file:copy,plain"
              "super+shift+ctrl+v=write_screen_file:paste,plain"
            ];
          };
        };
      };
    };
  };
}
