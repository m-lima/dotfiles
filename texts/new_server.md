# Change root password
```
$ passwd
```

# Change system hostname
```
vi /etc/hostname

# Optional for temporary application
$ hostname <new_hostname>
```

# Create new user
```
useradd <user>
# Just leave everything empty
```

# Add new user to sudoers
```
$ usermod -aG sudo <user>
```

# Change port for ssh

## Change sshd_config
```
$ vi /etc/ssh/sshd_config
# Change port
```

## Restart ssh
```
$ systemctl restart ssh
```

## Reconnect with new port

## Enable firewall
```
$ ufw allow <new_port>
$ ufw enable
```

## Reconnect as new user

# Disable root ssh login
```
$ vi /etc/ssh/sshd_config
# Set `PermitRootLogin` to `no`
```

# Rice

## Edit `/etc/update-motd.d/*` to adjust motd PAM motd

## Edit `/etc/motd` to adjust login motd
