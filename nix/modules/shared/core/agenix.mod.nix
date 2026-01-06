path:
{
  lib,
  config,
  util,
  pkgs,
  inputs,
  rootDir,
  ...
}:
let
  cfg = util.getOptions path config;
  host = config.celo.host.id;
  agenix = inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options = util.mkOptions path {
    pubkey = lib.mkOption {
      type = lib.types.coercedTo lib.types.path (
        x: if builtins.isPath x then builtins.readFile x else x
      ) lib.types.singleLineStr;
      default = /${rootDir}/secrets/pubkey/${host}/ssh.key.pub;
      example = "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host";
    };
    identityPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to a private SSH key to use as identity for decryption";
      example = "/etc/ssh/ssh_host_ed25519_key";
      default = "${config.celo.modules.core.disko.mounts.persist.mountpoint}/etc/ssh/ssh_host_ed25519_key";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ agenix.default ];

    age = {
      identityPaths = [ cfg.identityPath ];
      rekey = {
        hostPubkey = cfg.pubkey;
        masterIdentities = [
          {
            identity = /${rootDir}/secrets/key.age;
            pubkey = builtins.readFile /${rootDir}/secrets/key.pub;
          }
        ];
        storageMode = "local";
        localStorageDir = /${rootDir}/secrets/rekeyed/${host};
      };
    };
  };
}
