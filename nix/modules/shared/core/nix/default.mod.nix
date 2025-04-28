path:
{
  lib,
  config,
  util,
  ...
}:
let
  cfg = util.getOptions path config;
  host = config.celo.host.id;
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

      settings =
        let
          access-tokens = util.rageSecret config ./_secrets/${host}/access_tokens.rage;
        in
        {
          # Enable some experimental features
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        }
        // lib.optionalAttrs (builtins.length access-tokens > 0) {
          # Use access token with nix
          access-tokens = builtins.head access-tokens;
        };
    };
  };
}
