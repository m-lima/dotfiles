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

5. Format the drives

```
$ ./dotfiles/nix/init.sh <HOST> all [USER]
```

6. Generate the config

```
$ nixos-generate-config --no-filesystems --root /mnt
```

7. Put in the secrets

See [permanence.md](./permanence.md)

```
$ mkdir -p /mnt/persist/secrets/<USER>
$ mkpasswd > /mnt/persist/secrets/<USER>/passwordFile
$ ssh-keygen -t ed25519 -C "<USER>@<HOST>" -N '' -f "/mnt/persist/secrets/<USER>/id_ed25519"
```

8. Install NixOS

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
