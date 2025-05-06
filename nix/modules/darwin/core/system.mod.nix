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
  options = util.mkPath path {
    stateVersion = lib.mkOption {
      description = "See https://mynixos.com/nix-darwin/option/system.stateVersion";
      example = 5;
      type = lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.postUserActivation.text =
      let
        rsyncArgs = "--archive --checksum --chmod=-w --copy-unsafe-links --delete";
        source = "${config.system.build.applications}/Applications";
        target = "/Applications/Nix Trampolines";
      in
      ''
        mkdir -p "${target}"
        ${pkgs.rsync}/bin/rsync ${rsyncArgs} "${source}/" "${target}"
      '';
  };
}
