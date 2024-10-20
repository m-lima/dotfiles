# Permanent files

> https://github.com/NixOS/nixpkgs/pull/273384/files

- `/boot`
- `/nix`
- `/var/lib/nixos`
- `/etc/machine-id`
- `/var/lib/systemd`
- `/var/log`
- ` /var/log/journal`
- Make `users.mutableUsers = false` or:
  - `passwd`
  - `group`
  - `shadow`
  - `gshadow`
  - `subuid`
  - `subgid`

# Configuration changes

The persistent subvolume **must** be marked with `requiredForBoot`

# Expected files

## /persist/secrets/wireless.env

> https://search.nixos.org/options?show=networking.wireless.environmentFile&from=0&size=50&sort=relevance&type=packages&query=networking.wireless

## /persist/secrets/users/name.passwordFile

> https://search.nixos.org/options?show=users.users.%3Cname%3E.hashedPassword

A new hash can be created with:

```
$ mspasswd
$ # OR
$ print "VALUE" | mkpasswd -s > /persist/secrets/users/name.passwordFile
```

**Note:** Don't forget about root
