path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  ...
}:
let
  cfg = util.getOptions path config;
  user = config.celo.modules.core.user;
in
{
  config = lib.mkIf cfg.enable {
    home-manager = {
      users = {
        ${user.userName} = {
          home.activation = {
            rsync-home-manager-applications =
              let
                rsyncArgs = "--archive --checksum --chmod=-w --copy-unsafe-links --delete";
                source = "$genProfilePath/home-path/Applications";
                target = "${user.homeDirectory}/Applications/Home Manager Trampolines";
              in
              inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                mkdir -p "${target}"
                ${pkgs.rsync}/bin/rsync ${rsyncArgs} "${source}/" "${target}"
              '';
          };
        };
      };
    };
  };
}
