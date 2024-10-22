# Initializing

1. Use the minimal base image for NixOS and boot into the machine as root

```
$ sudo -i
```

2. Enable **git**

```
$ nix-shell -p git
```

3. Clone this repository

```
$ cd ~
$ git clone https://github.com/m-lima/dotfiles
```

4. Format the drives

```
$ cd dotfiles/nix
$ nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko ./hosts/<HOST>/disko.nix
```

5. Generate the config

```
$ nixos-generate-config --no-filesystems --root /mnt
```

6. Put in the secrets

See [permanence.md](./permanence.md)

```
$ mkdir /mnt/persist/secrets
$ mkpasswd > /mnt/persist/secrets/<USER>.passwordFile
```

7. Install NixOS

```
$ nixos-install --flake .#<HOST>
```
