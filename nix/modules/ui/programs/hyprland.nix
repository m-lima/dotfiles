{
  pkgs,
  lib,
  config,
  util,
  ...
}:
let
  cfg = config.modules.ui.programs.hyprland;
in {
  options = {
    modules.ui.programs.hyprland = {
      enable = util.mkDisableOption "hyprland";
      sddm = {
        enable = util.mkDisableOption "SDDM";
      };
    };
  };

  config = util.mkIfUi config cfg.enable {
    programs.hyprland = {
      enable = true;
    };

    environment.systemPackages =
    let
      themes = pkgs.callPackage ./sddm/themes.nix {};
    in lib.mkIf cfg.sddm.enable [
      themes.sugarDark
    ];

    services.displayManager.sddm = lib.mkIf cfg.sddm.enable {
      enable = true;
      wayland.enable = true;
      theme = "sugar-dark";
    };
  };
}
