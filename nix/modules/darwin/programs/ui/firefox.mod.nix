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
  config = util.given.enforcedHome path config cfg.enable {
    home-manager = {
      programs.firefox.package = (pkgs.callPackage ./firefox.pkg.nix { });
    };

    # # Goto
    # {
    #   "key_undo": {
    #     "modifiers": "meta",
    #     "key": "Z"
    #   },
    #   "key_redo": {
    #     "modifiers": "meta,shift",
    #     "key": "Z"
    #   },
    #   "key_cut": {
    #     "modifiers": "meta",
    #     "key": "X"
    #   },
    #   "key_copy": {
    #     "modifiers": "meta",
    #     "key": "C"
    #   },
    #   "key_paste": {
    #     "modifiers": "meta",
    #     "key": "V"
    #   },
    #   "key_selectAll": {
    #     "modifiers": "meta",
    #     "key": "A"
    #   },
    #   "key_find": {
    #     "modifiers": "meta",
    #     "key": "F"
    #   },
    #   "key_fullZoomReduce": {
    #     "modifiers": "meta",
    #     "key": "-"
    #   },
    #   "key_fullZoomReset": {
    #     "modifiers": "meta",
    #     "key": "0"
    #   },
    #   "key_enterFullScreen": {
    #     "modifiers": "meta",
    #     "keycode": "VK_ENTER"
    #   },
    #   "key_toggleToolbox": {
    #     "modifiers": "meta,shift",
    #     "key": "I"
    #   },
    #   "key_webconsole": {
    #     "modifiers": "meta,shift",
    #     "key": "K"
    #   },
    #   "goBackKb": {
    #     "modifiers": "meta",
    #     "key": "["
    #   },
    #   "goForwardKb": {
    #     "modifiers": "meta",
    #     "key": "]"
    #   },
    #   "key_reload": {
    #     "modifiers": "meta",
    #     "key": "R"
    #   },
    #   "key_reload_skip_cache": {
    #     "modifiers": "meta,shift",
    #     "key": "R"
    #   }
    # }
  };
}
