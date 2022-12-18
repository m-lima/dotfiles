(
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
  } else {
    []
  };

  # clipwd
  let clipwd = if not (which clip | is-empty) {
    if not (which paste | is-empty) {
      [
        'export alias cpwd = ($env.PWD | clip | null)'
        'export alias ppwd = cd (paste)'
      ]
    } else {
      [
        'export alias cpwd = ($env.PWD | clip | null)'
        'export alias ppwd = cd (clip)'
      ]
    }
  } else if $nu.os-info.name == 'macos' {
    [
      'export alias cpwd = ($env.PWD | pbcopy | null)'
      'export alias ppwd = cd (pbpaste)'
    ]
  } else if not (which xclip | is-empty) {
    [
      'export alias cpwd = ($env.PWD | xclip -se c | null)'
      'export alias ppwd = cd (xclip -o -se c)'
    ]
  } else {
    [
      ('export alias cpwd = ($env.PWD | save ' + ([$nu.temp-path $env.USER] | path join))
      ('export alias ppwd = cd (' + ([$nu.temp-path $env.USER] | path join)) +')')
    ]
  };

  [$directories $vi $clipwd]
) | str join (char newline) | save -a alias.gen.nu
use alias.gen.nu *
