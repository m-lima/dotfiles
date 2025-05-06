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
    tmuxStart = lib.mkEnableOption "wrap the terminal in a tmux session by default";
    pkg = lib.mkOption {
      readOnly = true;
      visible = false;
      type = lib.types.package;
      default = pkgs.alacritty;
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
      home = {
        packages = [ cfg.pkg ];
      };

      xdg.configFile."alacritty/alacritty.toml".text =
        ''''
        + builtins.readFile /${rootDir}/../alacritty/config/colors.toml
        + builtins.readFile /${rootDir}/../alacritty/config/options.toml
        + ''
          [keyboard]
          bindings = [
            { key = "V",              mods = "Control|Shift", action = "None" },
            { key = "C",              mods = "Control|Shift", action = "None" },
            { key = "F",              mods = "Control|Shift", action = "None" },
            { key = "B",              mods = "Control|Shift", action = "None" },
            { key = "0",              mods = "Control",       action = "None" },
            { key = "=",              mods = "Control",       action = "None" },
            { key = "+",              mods = "Control",       action = "None" },
            { key = "NumpadAdd",      mods = "Control",       action = "None" },
            { key = "-",              mods = "Control",       action = "None" },
            { key = "NumpadSubtract", mods = "Control",       action = "None" },

            { key = "F",              mods = "Control|Super", action = "None" },
            { key = "Q",              mods = "Super",         action = "None" },
            { key = "W",              mods = "Super",         action = "None" },

            { key = "Return",         mods = "Alt",           action = "ToggleFullscreen" },

            { key = "V",              mods = "Super",         action = "Paste" },
            { key = "C",              mods = "Super",         action = "Copy" },
            { key = "F",              mods = "Super",         action = "SearchForward" },
            { key = "B",              mods = "Super",         action = "SearchBackward" },
            { key = "0",              mods = "Super",         action = "ResetFontSize" },
            { key = "=",              mods = "Super",         action = "IncreaseFontSize" },
            { key = "+",              mods = "Super",         action = "IncreaseFontSize" },
            { key = "NumpadAdd",      mods = "Super",         action = "IncreaseFontSize" },
            { key = "-",              mods = "Super",         action = "DecreaseFontSize" },
            { key = "NumpadSubtract", mods = "Super",         action = "DecreaseFontSize" },
            { key = "Return",         mods = "Super",         action = "ToggleFullscreen" },

            { key = "Z",              mods = "Super",         action = "DecreaseFontSize" },
            { key = "Z",              mods = "Super",         action = "DecreaseFontSize" },
            { key = "Z",              mods = "Super",         action = "DecreaseFontSize" },
            { key = "Z",              mods = "Super|Shift",   action = "IncreaseFontSize" },
            { key = "Z",              mods = "Super|Shift",   action = "IncreaseFontSize" },
            { key = "Z",              mods = "Super|Shift",   action = "IncreaseFontSize" },
            { key = "N",              mods = "Super",         action = "CreateNewWindow"  },
        ''
        + (lib.optionalString (cfg.tmuxStart && prg.zsh.enable) ''
          { key = "N", mods = "Super|Shift", command = { program = "${cfg.pkg}/bin/alacritty", args = ["-e", "${pkgs.zsh}/bin/zsh"] } },
        '')
        + ''
          ]
        ''
        + (lib.optionalString hackCfg.enable (builtins.readFile /${rootDir}/../alacritty/config/font.toml))
        + (lib.optionalString cfg.tmuxStart ''
          [env]
          TERM = "alacritty-direct"
          [terminal]
          shell = { program = "${pkgs.bash}/bin/bash", args = ["-l", "-c", "${tmuxCfg.pkg}/bin/tmux"] }
        '');
    };
  };
}
