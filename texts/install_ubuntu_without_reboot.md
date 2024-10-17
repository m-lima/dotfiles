# Using ISO

## Download the ISO

```
# Example (maybe no wget, maybe different version/url):
$ wget https://ubuntu.hi.no/releases/22.04.3/ubuntu-22.04.3-live-server-amd64.iso
```

## Mount the ISO
```
$ mkdir /mnt/iso
$ mount -o loop <file.iso>
```

## Find the squashfs file
```
$ find /mnt/iso -name '*.squashfs'
```

## Mount the squashfs
```
$ mkdir /mnt/squash
$ mount -o loop -t squashfs <file.squashfs> /mnt/squash
```

## Root into it
```
$ chroot /mnt/squash
```

# Using base image
> Reference https://askubuntu.com/questions/1290075/xubuntu-20-04-minimal-installation/1293305#1293305

## Locate the desired image
Browse (http://cdimage.ubuntu.com/ubuntu-base/releases/)

## Download the tar
```
$ wget http://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.3-base-amd64.tar.gz
```

## Extract it
```
$ mkdir base
$ tar -xzvf <file.tar.gz> -C base
```

## Update the resolver
```
$ echo -n 'nameserver <nameserver>' >> base/etc/resolv.conf
```

## Bind the virtual files
```
$ mount --bind /dev base/dev
$ mount --bind /dev/pts base/dev/pts
$ mount --bind /proc base/proc
$ mount --bind /sys base/sys
```

## Chroot in
```
$ chroot base
```

## Unbind the virtual files
```
$ umount base/sys
$ umount base/proc
$ umount base/dev/pts
$ umount base/dev
```

> Did not continue on

# Using the current disk

## Back up the bare disk
```
$ mkdir /mnt/root
$ mount /dev/sdX /mnt/root
$ rsync -a /mnt/root old-root
$ umount /mnt/root
```

## Create new partition
```
# Using BTRFS as an example
$ mkfs.btrfs -f -L root /dev/sdX
```

### BTRFS: Create subvolumes
```
$ mount -o ssd,noatime,space_cache,compress=zstd -t btrfs /dev/sda3 /mnt/root
$ btrfs subvolume create /mnt/root/@
$ btrfs subvolume create /mnt/root/@.snapshots
$ btrfs subvolume create /mnt/root/@root
$ btrfs subvolume create /mnt/root/@home
$ btrfs subvolume create /mnt/root/@<user>
$ btrfs subvolume create /mnt/root/@opt
$ btrfs subvolume create /mnt/root/@var
$ btrfs subvolume create /mnt/root/@podman
```

## Replace the root mount with the targeted mount
```
# Using BTRFS as an example
$ umount /mnt/root
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@ -t btrfs /dev/sda3 /mnt/root
```

### BTRFS: Create and mount subvolumes
```
$ mkdir /mnt/root/root
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@root -t btrfs /dev/sda3 /mnt/root/root
$ chmod 700 /mnt/root/root
$
$ mkdir /mnt/root/home
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@home -t btrfs /dev/sda3 /mnt/root/home
$
$ mkdir /mnt/root/home/<user>
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@<user> -t btrfs /dev/sda3 /mnt/root/home/<user>
$ chown UID:UID /mnt/root/home/<user>
$
$ mkdir /mnt/root/opt
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@opt -t btrfs /dev/sda3 /mnt/root/opt
$
$ mkdir /mnt/root/var
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@var -t btrfs /dev/sda3 /mnt/root/var
```

## Bring the backup back in
```
$ rsync -a old-root/ /mnt/root/
```

## Get new UUID
```
$ blkid
```

## Update fstab
```
$ vi /etc/fstab

# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during installation
# UUID=8cfb4588-3b3a-4772-affd-196b92cfa759 /               ext4     0       0
UUID=aaaaaaaa-bbbb-cccc-dddd-dddddddddddd /               btrfs   ssd,noatime,space_cache=v2,compress=zstd,subvol=@ 0       0
# /boot was on /dev/sda1 during installation
UUID=9dd693e9-0386-4721-b1c7-c0b8bf807bf6 /boot           ext4    defaults,noatime                                  0       0
```

## Update grub
```
$ mkdir /mnt/boot
$ mount /dev/sda2 /mnt/boot
$ chmod 644 /mnt/boot/grub/grub.cfg
$ vi /mnt/boot/grub/grub.cfg
# Replace UUID references, and add `rootflags=subvol=@`
# E.g: linux   /vmlinuz-5.15.0-25-generic root=UUID=4edb2045-6a8c-4baf-8c7d-1cf62f23c229 ro rootflags=subvol=@ net.ifnames=0 biosdevname=0 nomodese
```

## After a reboot
```
$ update-grub
```

### BTRFS: Make metadata DUP
```
$ btrfs balance start -mconvert=DUP /
```

# Using full-disk encryption

> Reference: https://www.cyberciti.biz/security/how-to-unlock-luks-using-dropbear-ssh-keys-remotely-in-linux/

This is independent from the above, and essentially a "wrapper" around it

## Make sure dm_crypt is available
```
$ mod_info dm_crypt
```

## Install cryptsteup
```
$ apt install cryptsetup
```

## Install dropbear initramfs
```
$ apt install dropbear-initramfs
```

## Get the IP information (optional)
```
$ ip addr
$ ip route
```

## Edit static IP config for dropbear (optional)
```
$ echo -n 'IP=<IP_ADDR>::<GATEWAY>:<SUBNET_MASK>:<HOST>' > /etc/initramfs-tools/initramfs.conf
```

> The full syntax is as follows for IPv4 and IPv6 staitc IP settings:
> ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:<dns-server-0-ip>:<dns-server-1-ip>:<ntp0-ip>

## Edit dropbear paramenters
In `/etc/dropbear/initramfs/dropbear.conf`
```
DROPBEAR_OPTIONS="-I 120 -j -k -p <PORT>"
```

* `-I`: Disconnect session if no traffic is transmitted or received in this amount of seconds
* `-j`: Disable ssh local port forwarding
* `-k`: Disable ssh remote port forwarding
* `-p`: Port to listen to
* `-s`: Disable password logins (optional)
* `-c`: Disregard command and always run this command (will come later)

## Add authorized keys
```
$ cat /home/<USER>/.ssh/authorized_keys >> /etc/dropbear/initramfs/authorized_keys
```

## Encrypt the drive

### Boot in recovery mode

### Back up the filesystem
```
$ mkdir /root/snaps
$ mount /dev/sda3 /mnt
$ btrfs send /dev/sda3/@.snapshots/_/<NAME> -f /root/snaps/_
# Repeat for all the other subvolumes
# or
$ for f in /mnt/*; do base=`basename $f`; src="$f/<NAME>"; dst="/root/snaps/${base}"; [ ! `ls $dst 2> /dev/null` ] && echo "$src -> $dst" && btrfs send $src -f $dst ; done
```

### Run cryptsetup
```
$ cryptsetup luksFormat --type luks2 /dev/sda3
$ cryptsetup luksOpen /dev/sda3 btrfs_crypt   # Remember this last name, it'll come later
```

### Prepare BTRFS
```
$ mkfs.btrfs -f -L root /dev/mapper/btrfs_crypt
$ mount -o ssd,noatime,space_cache,compress=zstd -t btrfs /dev/sda3 /mnt
$ btrfs subvolume create /mnt/root/@.snapshots
```

### Restore the filesystem
```
$ btrfs receive -f /root/snaps/_ /mnt/@.snapshots/@ -m /mnt
# Repeat for all the other subvolumes
$ btrfs subvolume snapshot @.snapshots/_/<NAME> /mnt/@
# Repeat for all the other subvolumes
```

## Chroot into the new filesystem
```
$ umount /mnt
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@ -t btrfs /dev/mapper/btrfs_crypt /mnt
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@root -t btrfs /dev/mapper/btrfs_crypt /mnt/root
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@home -t btrfs /dev/mapper/btrfs_crypt /mnt/home
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@<user> -t btrfs /dev/mapper/btrfs_crypt /mnt/home/<user>/
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@var -t btrfs /dev/mapper/btrfs_crypt /mnt/var
$ mount -o ssd,noatime,space_cache,compress=zstd,subvol=@opt -t btrfs /dev/mapper/btrfs_crypt /mnt/opt
$ mount /dev/sda2 /mnt/boot
$ mount --bind /dev /mnt/dev/
$ mount --bind /sys /mnt/sys/
$ mount --bind /proc /mnt/proc/
$ mount --bind /dev/pts /mnt/dev/pts/
$ chroot /mnt
```

## Add crypttab
```
$ blkid
$ echo '<crypt_name> UUID=<uuid for the root encrypted partition> none luks,discard' >> /etc/crypttab
# Here, <crypt_name> is the same name used in `cryptsetup luksOpen`
```

## Update fstab
```
$ blkid
# Replace the UUID with the new BTRFS UUID
```

## Update the boot
```
$ udate-grub
$ update-initramfs -u
```

## Update initramfs
```
$ update-initramfs -u
```

## Reboot
```
$ ssh -o 'UserKnownHostsFile=/dev/null' root@<host> -p <port>
```

## Lock dropbear into cryptsetup
Add `-c cryptroot-unlock` to `DROPBEAR_OPTIONS` in `/etc/dropbear/initramfs/dropbear.conf` and update initramfs
