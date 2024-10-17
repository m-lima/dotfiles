# Key concepts

- LUKS
- dm-crypt

# Things to think about

- Swap
  - Hibernation
    - Size should fit RAM?
    - What about the key to the adhoc swap partition
- Can/should the swap be in the same LUKS but under a separate LVM?
- What's the performance impact of the virtual volume?
- How will boot be handled?
- Can we create a thumbstick? Or use the network for fetching the key from the LAN?

# LUKS vs dm-crypt

https://stackoverflow.com/questions/71688533/luks-and-dm-crypt-distinction-responsibilities

Lets start from the kernel part:

    Device mapper is a kernel driver that allows creating new block devices from existing ones. It provides multiple additional features like RAID, caching or encryption through so called targets.
    dm-crypt is a device mapper target that provides transparent encryption. This means you can create a block device on top of your disk or partition and everything you write to this new device mapper device will be encrypted before the data is actually written to the disk. And vice versa for reading: if you read from the device, the data is read from the disk and decrypted before returning to you.
    dm-integrity is also a device mapper target, this one has a special metadata area for each block which are used to store checksum of the data block. This allows detection of data corruption.

Now the userspace level:

You can use device mapper directly, but it's not user friendly. Say you want to use dm-crypt directly -- to access the data you need to know the encryption algorithm, used IV and of course the key (which isn't short and easy to remember). It wouldn't be very practical to ask for these during boot.

That's where LUKS comes in. It provides two things: header and way to store (and manage) keys. Header allows system to identify the device as LUKS and contains all the metadata needed to work with the device. And key management allows you to safely store the encryption key on the disk, protected by easy to remember passphrase (or key file, TPM, FIDO token, etc.).

So the LUKS format only gives system all the information needed to correctly set the device mapper device up. You'll most likely use cryptsetup for that -- tool and library that can read the LUKS metadata, decrypt the key stored in there and correctly create the DM device.

The difference between LUKSv1 and LUKSv2 is in the format of the metadata. LUKSv2 adds some features, one of them is the authenticated encryption, which is combination of dm-crypt and dm-integrity -- integrity provides the checksums and crypt makes sure the checksums are also encrypted so it isn't possible to simply change both data and the cheksum hiding the change (plain integrity doesn't protect against this, it can be used only to protect about random data changes like bit rot). So authenticated encryption is provided by combining two technologies with LUKSv2 -- the metadata in the LUKSv2 header tell how the two device mapper targets needs to be configured and combined to get the data.

# Decision

Will go for three partitions:

- boot
- root
- swap

Where `root` is a LUKS volume, and `swap` uses "random encryption". E.g.:

```
  swapDevices = [ {
    device = "/dev/sdXY";
    randomEncryption.enable = true;
  } ];
```

> TODO: Run `cryptsetup benchmark` to get the fastest algorithm

It's also decided that there will be no hibernation. This is why the swap is OK to have a random encryption and to be outside of LUKS.

Another decision is to go for [impermanence](https://github.com/nix-community/impermanence), but without using `tmpfs`. I cannot afford the RAM to use `tmpfs`. Instead, the whole drive will be `btrfs`, with the root partition being wiped on every reboot.

# Steps:

## Get blocks

```
$ lsblk
```

## Check the sector sizes

> https://wiki.archlinux.org/title/Advanced_Format

## Make partitions

```
$ parted /dev/<device>
! mklabel gpt
! mkpart luks 512MB -<swap>
! mkpart swap linux-swap -<swap> 100%
! mkpart boot fat32 1MB 512MB
! set 3 esp on
```

> Example variables:
>
> - **device**: sda
> - **swap**: 8GB

## Encrypt

```
$ cryptsetup luksFormat --type luks2 /dev/<partition>
```

Type `YES` and then the password.

> Example variables:
>
> - **partition**: sda1 (corresponds to the partition labeled "luks" above)

### Optional: Create a key file

```
$ dd if=/dev/random of=<key> bs=4096 count=1
$ cryptsetup luksAddKey /dev/<device> <key>
```

> Example variables:
>
> - **key**: /hdd.key
> - **device**: sda1

## Prepare encrypted drive

### Open the volume

```
$ cryptsetup luksOpen /dev/<device> <enc_name>
```

> Example variables:
>
> - **device**: sda1
> - **enc_name**: crypt

### Format the volumes

```
$ mkfs.btrfs -L <vol_name> /dev/mapper/<enc_name>
$ mkswap -L <swap_name> /dev/<swap_device>
$ mkfs.fat -F 32 -n <boot_name> /dev/<boot_device>
```

> Example variables:
>
> - **vol_name**: btrfs
> - **enc_name**: crypt
> - **swap_name**: swap
> - **swap_device**: sda2
> - **boot_name**: boot
> - **boot_device**: sda3

### Prepare subvolumes

https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html

```
$ mount -o noatime,compress=zstd:3 -t btrfs /dev/mapper/<enc_name> /mnt
$ btrfs subvolume create /mnt/@
$ btrfs subvolume create /mnt/@snapshots
$ btrfs subvolume create /mnt/@nix
$ btrfs subvolume create /mnt/@persist
$ btrfs subvolume create /mnt/@log
$ btrfs subvolume snapshot -r /mnt/@ /mnt/@snapshots/_blank
$ umount /mnt
```

> Example variables:
>
> - **enc_name**: crypt

### Seal layout on NixOS

Mount the root

```
$ mount -o noatime,compress=zstd:3,subvol=@ -t btrfs /dev/mapper/<enc_name> /mnt
```

Prepare the mounting points

```
$ mkdir /mnt/.btrfs
$ mkdir /mnt/volume
$ mkdir /mnt/snapshots
$ mkdir /mnt/nix
$ mkdir /mnt/persist
$ mkdir /mnt/var
$ mkdir /mnt/var/log
```

Mount the subvolumes onto the root

```
$ mount -o noatime,compress=zstd:3 -t btrfs /dev/mapper/<enc_name> /mnt/.btrfs/volume
$ mount -o noatime,compress=zstd:3,subvol=@snapshots -t btrfs /dev/mapper/<enc_name> /mnt/.btrfs/snapshots
$ mount -o noatime,compress=zstd:3,subvol=@nix -t btrfs /dev/mapper/<enc_name> /mnt/nix
$ mount -o noatime,compress=zstd:3,subvol=@persist -t btrfs /dev/mapper/<enc_name> /mnt/persist
$ mount -o noatime,compress=zstd:3,subvol=@log -t btrfs /dev/mapper/<enc_name> /mnt/var/log

```

> Example variables:
>
> - **enc_name**: crypt

Mount the other partitions for NixOS to pick them up

```
$ mkdir /mnt/boot
$ mount -o umask=077 /dev/<boot_device> /mnt/boot
$ swapon /dev/<swap_device>
```

> Example variables:
>
> - **boot_device**: sda3
> - **swap_device**: sda2

Seal the deal

```
$ nixos-generate-config --root /mnt
```

### Fix configuration to operate with encrypted drive

#### In `/mnt/etc/nixos/hardware-configuration.nix`

- We need to add `noatime` and `compress=zstd:3` to the btrfs parameters for all volumes
- It is important to encrypt the swap. We need to add `randomEncryption.enable = true` to the swap device.
- It is not possible to use the disk UUID for the swap since it will be erased on every boot. It must use `/dev/disk/by-partuuid/<uuid>`, where the **partuuid** value can be grabbed by `ls`ing the given directory.

#### In `/mnt/etc/nixos/configuration.nix`

- **TODO:** Need to confirm if `GRUB` is needed in UEFI or if `systemd-boot` is enough
- We need to tell initrd to decrypt the luks volume by adding `boot.initrd.luks.devices.<enc_name>.device = "/dev/disk/by-uuid/<uuid>";`

> Example variables:
>
> - **enc_name**: crypt
