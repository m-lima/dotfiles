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
$ cd dotfiles/nix
$ nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./hosts/<HOST>/disko.nix
```

6. Generate the config

```
$ nixos-generate-config --no-filesystems --root /mnt
```

7. Put in the secrets

See [permanence.md](./permanence.md)

```
$ mkdir /mnt/persist/secrets
$ mkpasswd > /mnt/persist/secrets/<USER>.passwordFile
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
```
