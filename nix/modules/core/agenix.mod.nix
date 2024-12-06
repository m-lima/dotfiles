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
  agenix = inputs.agenix-rekey.packages.${pkgs.system};
in
{
  options = util.mkOptions path {
    pubkey = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (
        x: if builtins.isPath x then builtins.readFile x else x
      ) lib.types.singleLineStr;
      default = ../../secrets/pubkey/${config.celo.host.id}/ssh.key.pub;
      example = "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rage
      agenix.default
    ];

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
        localStorageDir = ../../secrets/rekeyed/${config.celo.host.id};
      };
    };

    home-manager = util.withHome config { home.packages = with pkgs; [ rage ]; };
  };
}
