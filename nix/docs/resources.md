# Nix bootstraping

https://nixos-and-flakes.thiscute.world/

# Dotfiles examples

https://github.com/mobsenpai/hana/?
https://codeberg.org/Gipphe/dotfiles

# Home manager options

https://nix-community.github.io/home-manager/options.xhtml

# Searching for packages

`nix search nixpkgs <package>`

# Find firefox add-on IDs

`https://addons.mozilla.org/api/v5/addons/search/?q=<NAME>`
And extract `gui`

# Compare locales

https://lh.2xlibre.net/locales/

# Getting the hash for fetchUrl

`nix store prefetch-file`

```
$ nixrpl
> map (x: if (builtins.hasAttr "url" x.passthru) then "nix store prefetch-file --name '${x.name}' '${x.passthru.url}'" else "nix run nixpkgs#nix-prefetch-github -- ${x.passthru.github}") (builtins.filter (x: (builtins.hasAttr "passthru" x) && ((builtins.hasAttr "url" x.passthru) || (builtins.hasAttr "github" x.passthru))) (config.environment.systemPackages ++ config.home-manager.users.celo.home.packages ++ config.home-manager.users.celo.programs.neovim.extraPackages ++ config.home-manager.users.celo.programs.neovim.plugins))
```

```
$ nixexpr --raw 'builtins.concatStringsSep "" (map (x: if (builtins.hasAttr "url" x.passthru) then "nix store prefetch-file --name ${x.name} ${x.passthru.url}\n" else "nix run nixpkgs#nix-prefetch-github -- ${x.passthru.github}\n") (builtins.filter (x: (builtins.hasAttr "passthru" x) && ((builtins.hasAttr "url" x.passthru) || (builtins.hasAttr "github" x.passthru))) (config.environment.systemPackages ++ config.home-manager.users.celo.home.packages ++ config.home-manager.users.celo.programs.neovim.extraPackages ++ config.home-manager.users.celo.programs.neovim.plugins)))' 2> /dev/null | sed 's/\\n/\n/g'
```
