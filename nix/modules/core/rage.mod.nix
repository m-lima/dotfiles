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
  options = util.mkOptions path {
    pubkey = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (
        x: if builtins.isPath x then builtins.readFile x else x
      ) lib.types.str;
      default = "/etc/ssh/ssh_host_rsa_key.pub";
      example = "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ rage ];

    age = {
      rekey = {
        hostPubkey = cfg.pubkey;
        masterIdentities = [
          {
            identity = ../../secrets/key.age;
            pubkey = "age1lgp45wxrz266fvw7lwgsuyu5cw35gjq9a8zqldva2vgs24xe4fgszksnrj";
          }
        ];
        storageMode = "local";
        localStorageDir = ../../secrets/rekeyed/${config.celo.modules.core.nixos.hostName};
      };
    };

    home-manager = util.withHome config { home.packages = with pkgs; [ rage ]; };
  };
}
