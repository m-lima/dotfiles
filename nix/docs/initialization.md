# Initializing

1. Use the minimal base image for NixOS and boot into the machine as root

```
$ sudo -i
```

2. Optionally [enable WiFi](#wifi)

3. Enable **git**

```
$ nix-shell -p git
```

4. Clone this repository

```
$ cd ~
$ git clone https://github.com/m-lima/dotfiles
```

5. Create the host file

```
$ mkdir ./nix/hosts/<HOST>
$ vi ./nix/hosts/<HOST>/default.nix
```

6. Format the drives

```
$ ./dotfiles/nix/init.sh <HOST> prepare [USER]
```

7. Generate the config

```
$ nixos-generate-config --no-filesystems --root /mnt
$ cp /mnt/etc/nixos/hardware-configuration.nix ./nix/hosts/<HOST>/.
```

8. Put in the secrets

See [permanence.md](./permanence.md)

```
$ mkdir -p /mnt/persist/secrets/<USER>
$ mkpasswd > /mnt/persist/secrets/<USER>/passwordFile
$ ssh-keygen -t ed25519 -C "<USER>@<HOST>" -N '' -f "/mnt/persist/secrets/<USER>/id_ed25519"
```

9. Copy the public key

```
$ mkdir ./nix/secrets/pubkey/<HOST>
$ cp /etc/ssh/ssh_host_ed25519_key.pub ./nix/secrets/pubkey/<HOST>/ssh.key.pub
```

10. Rekey the secrets

```
$ nix shell github:oddlama/agenix-rekey
$ cp /mnt/persist/secrets/<USER>/id_ed25519.pub ./modules/services/ssh/secrets/<USER>-<HOST>.pub
# Encrypt /mnt/persist/secrets/<USER>/id_ed25519 into ./modules/services/ssh/secrets/<USER>-<HOST>.age
$ agenix rekey
$ git add .
```

11. Install NixOS

```
$ nixos-install --flake .#<HOST>
```

# WiFi

1. Enable `wpa_supplicant`

```
$ systemctl start wpa_supplicant
```

2. Initialize the configuration

```
$ wpa_cli
add_network
0

set_network 0 ssid "myhomenetwork"
OK

set_network 0 psk "mypassword"
OK

set_network 0 key_mgmt WPA-PSK
OK

enable_network 0
OK

quit
```

3. Create WiFi secret file

```
cat << EOF >> /persist/secrets/wifi.env
SSID="SSID"
PSK="SECRET"
EOF
```

## Recovering from bad internet connection

1. Boot into NixOS stick

2. Repeat steps **1** and **2** from [above](#wifi)

3. Repeat steps **3** and **4** from the [main flow](#initializing)

4. Mount the disks

```
$ ./dotfiles/nix/init.sh <HOST> mount
```

5. Entert the system

```
$ nixos-enter --root /mnt
```

# From the network

> https://github.com/nix-community/nixos-images

1. Download the image from `https://github.com/nix-community/nixos-images/releases`. e.g. `https://github.com/nix-community/nixos-images/releases/download/nixos-24.11/nixos-kexec-installer-x86_64-linux.tar.gz`

2. Copy the public key to `/root/.ssh/authorized_keys`

3. Untar `tar -vxf <downloaded file>`

4. Run `./kexec/run`

5. Re-login and run `nix-channel --update`

6. Continue as a normal installation
