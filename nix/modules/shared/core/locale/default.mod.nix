# TODO: Make the UCI equivalent and load it into QT/KDE
path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptionsEnable path;

  config = lib.mkIf cfg.enable {
    # i18n = {
    #   glibcLocales =
    #     (pkgs.glibcLocales.override {
    #       allLocales = false;
    #       locales = [
    #         "en_US.UTF-8/UTF-8"
    #         "C.UTF-8/UTF-8"
    #         "en_XX.UTF-8/UTF-8"
    #       ];
    #     }).overrideAttrs
    #       (
    #         finalAttrs: prevAttrs: {
    #           patches = prevAttrs.patches ++ [ ./en_XX.patch ];
    #         }
    #       );
    #   defaultLocale = lib.mkForce "en_XX.UTF-8";
    # };
  };
}
