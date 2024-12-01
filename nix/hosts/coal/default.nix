{
  imports = [ ./hardware-configuration.nix ];

  celo = {
    profiles.base.enable = true;
    profiles.hyprland.enable = true;
    profiles.ui.enable = true;

    modules = {
      core = {
        disko = {
          device = "/dev/nvme0n1";
          luks = true;
          swap = "8G";
        };
        nixos = {
          hostName = "coal";
          timeZone = "Europe/Amsterdam";
        };
        user = {
          userName = "celo";
          homeDirectory = "/home/celo";
        };
      };
      hardware = {
        wifi.enable = true;
        bluetooth.enable = true;
      };
      programs = {
        simpalt = {
          symbol = "₵";
        };
      };
    };
  };

  age.rekey = {
    hostPubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEdF76DqhT29CS5oIfwUOd69XJfHDHwZ5A+jTVLIC7pqixpnPb5l3vJwsLvFjgjlj/tr5w0pK8U4JlAbdgeREykORIKRt48FSJ27msxBNtLPPpeWMK17uQamcVQgheaWdMHeXfB+XvrXPsVPK7/Qx5dRPyiPTo6z86khNONvSVJzEJFADsr/SnvW/ZfaUjVgIb53js1l2Up+QrVYlnfZVRAf9qEIHoL50dERQA5v1Jv/3SGnv/Dd9xzWm1vZ8JlTE5M0cXFxHwxjiQaqpgA9l5aby3AcF7lGaxvkmY5vOlqdsk+tcSebARRTrZni6rDtqhwbtmTpxeHzGL+7bmTzBfwKrFMZZhTa3rSSSU38LM2fbGCM30pNp4liJdKCo7ov+1nW6TUX6pC+CkNFBfI5zQHqblMb/x/EqNXGXNR6JhLGBQL0cZDZi5N61WJKwCs+8e1l6/Vw88M3/lA+7ywU+jmOVecEo4BuIg3LeUvsfIg7y5m2h21vlBQaA4GHBVixrdtY56g0nRNtngLU4cDb0H+ZnKFngZbU3YRoUI7xssWnjOTlwRmUs13onW4tUm2dP3K8Rls6Eyjr/VApRZ8TheHyRSLjh7t1IIHuIylW96Xe8IKg0nnHWd/rimcM0yWWUDYZra9HOjMCgzvofgGbHe7z1V4rNV/tZRoS5pSY9obw==";
    masterIdentities = [
      {
        identity = ../../secrets/celo.key.age;
        pubkey = "age1ulzx72h7h7c6qjld4a72l2zymd6dll8nug6x7x56h62swd9cy9kss9amjs";
      }
    ];
    storageMode = "local";
    localStorageDir = ./. + "/secrets/rekeyed/coal";
  };
}
