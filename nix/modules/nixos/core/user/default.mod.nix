path:
{
  lib,
  config,
  util,
  options,
  ...
}:
let
  cfg = util.getOptions path config;
  host = config.celo.host.id;
in
{
  options = util.mkPath path {
    motd = options.users.motd;
  };

  config = lib.mkIf cfg.enable (
    (util.mkPath path {
      usersDirectory = "home";
    })
    // {
      users = {
        age.secrets = {
          ${util.mkSecretPath path host} = {
            rekeyFile = ./_secrets/${host}/password.age;
          };
        };

        ${cfg.userName} = {
          isNormalUser = true;
          hashedPasswordFile = config.age.secrets.${util.mkSecretPath path host}.path;
          extraGroups = [ "wheel" ];
        };
        motd = cfg.motd;
      };
    }
  );
}
