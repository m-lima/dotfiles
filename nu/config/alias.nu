use ~/.config/m-lima/nu/alias.gen.nu *

module aliases {
  export def regen [] {
    # Directories
    let directories = [
      'export alias l = ls -a'
      'export alias ll = ls -la'
      'export alias md = mkdir'
      'export alias rd = rmdir'
    ];

    # Vim
    let vi = if not (which nvim | is-empty) {
      'export alias vi = nvim'
    } else if not (which vim | is-empty) {
      'export alias vi = vim'
    };

    # clipwd
    let clipwd = if not (which clip | is-empty) {
      if not (which paste | is-empty) {
        [
          'export def cpwd [] { $env.PWD | clip | null }'
          'export alias ppwd = cd (paste)'
        ]
      } else {
        [
          'export def cpwd [] { $env.PWD | clip | null }'
          'export alias ppwd = cd (clip)'
        ]
      }
    } else if $nu.os-info.name == 'macos' {
      [
        'export def cpwd [] { $env.PWD | pbcopy | null }'
        'export alias ppwd = cd (pbpaste)'
      ]
    } else if not (which xclip | is-empty) {
      [
        'export def cpwd [] { $env.PWD | xclip -se c | null }'
        'export alias ppwd = cd (xclip -o -se c)'
      ]
    } else {
      [
        ('export def cpwd [] { $env.PWD | save --force ' + ([$nu.temp-path $env.USER] | path join) + '}')
        ('export alias ppwd = cd (' + ([$nu.temp-path $env.USER] | path join)) +')')
      ]
    };

    let lazygit = if not (which lazygit | is-empty) {
      'export alias lg = lazygit'
    };

    let bat = if not (which batcat | is-empty) {
      [
        'export alias bat = batcat'
        'export alias bbat = bat --paging=auto --style=auto'
      ]
    } else if not (which bat | is-empty) {
      'export alias bbat = bat --paging=auto --style=auto'
    };

    [$directories $vi $clipwd $lazygit $bat]
    | flatten
    | str join (char newline)
    | save --force ~/.config/m-lima/nu/alias.gen.nu
  }
}

use aliases
let-env ALIASES_LOADED = true
