# Collect garbage

```
$ sudo nix-collect-garbage -d
```

Also worth finding `/result`s and `/.direnv` and others around the system:
> [!note] This command will actually remove broken/stale links
```
$ nix-store --gc --print-roots
```

Also, rust and node can be quite heavy, especially if a repo is dormant:
```
$ fd '^target$' ~/code -t d --no-ignore
$ fd '^node_modules$' ~/code -t d --no-ignore --prune
$ fd '^\.direnv$' ~/code -t d --no-ignore --hidden --prune
```


# Mac

## Finding which settings to change

```
$ fd . ~/Library/Preferences -t f -X ls -laht | head -10
```

## Interacting with the settings

```
$ defaults read com.apple.TV
$ defaults read com.apple.TV updateLevel
$ defaults read -g AppleICUNumberSymbols
$ deafults delete com.apple.TV updateLevel
```

# Getting the hash for derivations

## For fetchUrl

```
$ nix store prefetch-file --name <${pname}-${version} of the package, aka ${name}> <url>
```

## For fetchFromGitHub

```
$ nix run nixpkgs#nix-prefetch-github -- <owner> <repo> --rev <rev>
```

## To scan the `*.pkg.nix` in the repo

```
$ nixexpr --raw 'builtins.concatStringsSep "" (map (x: if (builtins.hasAttr "url" x.passthru) then "nix store prefetch-file --name ${x.name} ${x.passthru.url}\n" else "nix run nixpkgs#nix-prefetch-github -- ${x.passthru.github}\n") (builtins.filter (x: (builtins.hasAttr "passthru" x) && ((builtins.hasAttr "url" x.passthru) || (builtins.hasAttr "github" x.passthru))) (config.environment.systemPackages ++ config.home-manager.users.celo.home.packages ++ config.home-manager.users.celo.programs.neovim.extraPackages ++ config.home-manager.users.celo.programs.neovim.plugins)))' 2> /dev/null | sed 's/\\n/\n/g'
```

Or, manually:

```
$ nixrpl
> map (x: if (builtins.hasAttr "url" x.passthru) then "nix store prefetch-file --name '${x.name}' '${x.passthru.url}'" else "nix run nixpkgs#nix-prefetch-github -- ${x.passthru.github}") (builtins.filter (x: (builtins.hasAttr "passthru" x) && ((builtins.hasAttr "url" x.passthru) || (builtins.hasAttr "github" x.passthru))) (config.environment.systemPackages ++ config.home-manager.users.celo.home.packages ++ config.home-manager.users.celo.programs.neovim.extraPackages ++ config.home-manager.users.celo.programs.neovim.plugins))
```

# Netstat

```
$ nix-shell -p net-tools --run 'sudo netstat -tulpn'
```

# System unit hardness

```
$ systemd-analyze security [unit]
```

# Find out which version of CPU microcode can be used

Because nixos doesn't allow `/lib64/ld-linux-x86-64.so.2` to run, we need some extra steps

First, get the ld from the store. Here, `cat` is a pretty common executable

```
$ ldd $(which cat)
```

It will print the `so` for `ld`

```
$ <ld.so> --help
```

# Upload derivation to the store

```
$ nix copy --to ssh://<host> -s <derivation>
```

Where `derivation` could be a `./result` or a global `/run/current-system`

# Firefox

## Find firefox add-on IDs

`https://addons.mozilla.org/api/v5/addons/search/?q=<NAME>`
And extract `guid`

## Keyboad shortcuts

Goto [about:keyboard], make the changes, then:

```
$ cat ~/.config/mozilla/firefox/default/customKeys.json
```
