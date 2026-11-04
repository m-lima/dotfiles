path:
{
  lib,
  config,
  util,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  cache =
    util.secret.rage.orElse config /${rootDir}/secrets/shared/servers/nix/cache.rage
      "localhost";
in
{
  options = util.mkOptions path { description = "home manager"; };

  config = lib.mkIf cfg.enable {
    # Allow all packages, regardless of license
    nixpkgs.config.allowUnfree = true;

    nix = {
      # Automatic garbage collection
      gc = {
        automatic = true;
        options = "--delete-older-than 1w";
      };

      optimise = {
        automatic = true;
      };

      settings = {
        # Enable some experimental features
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        access-tokens = util.secret.rage.mkIf config ./_secrets/access_tokens.rage;

        # Add cache
        substituters = [ "https://${cache}" ];
        trusted-public-keys = [ "${cache}:d5f3OptR3pkL3kUU1eElQxlISPWylkCGthlOZ9qt+Mw=" ];
      };
    };
  };
}
