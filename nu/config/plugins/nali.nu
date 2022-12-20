export-env {
  load-env {
    BD_HISTORY: []
    COMPLETERS: (
      $env.COMPLETERS | append {
        name: fd
        code: { |args| fd_completer $args }
      }
    )
    HOOKS: (
      $env.HOOKS | upsert env_change { |hooks|
        let entry = {
          condition: {|before, after| $before != null}
          code: {|before, after| let-env BD_HISTORY = ($env.BD_HISTORY | append $before)}
        }

        let ref = ($hooks | get -i env_change.PWD)

        if $ref == null {
          {
            PWD: [
              $entry
            ]
          }
        } else {
          $ref | append $entry
        }
      }
    )
  }
}

# Navigates to a preconfigured location
export def-env fd [base?: string@fd_cmp, path?: string] {
  let span = (metadata $base).span

  let target = if $base == null {
    '~'
  } else {
    let entry = (open ~/.config/m-lima/fd/config
      | lines
      | split column ':' cmd base
      | where cmd == $base
      | first
    )

    if $entry == null {
      error make {
        msg: 'Invalid parameter'
        label: {
          text: 'Location not found'
          start: $span.start
          end: $span.end
        }
      }
    }

    if $path == null {
      $entry.base
    } else {
      [$entry.base $path] | path join
    }
  }

  cd $target
}

def fd_cmp [] {
  open ~/.config/m-lima/fd/config
  | lines
  | split column ":" value description
}

def fd_completer [args] {
    if ($args | length) > 2 {
      return
    }

    let base = ($args | get -i 0)
    let path = ($args | get -i 1)

    if $base == null {
      return
    }

    let entry = try {
      open ~/.config/m-lima/fd/config
      | lines
      | split column ':' cmd path
      | where cmd == $base
      | first
    } catch {
      return
    }

    let path = if $path == null {
      ''
    } else if ($path | str starts-with '`') {
      $path | str replace -a '`' ''
    } else {
      $path
    }

    try {
      cd $entry.path
      ls $'($path)*'
      | where type == 'dir' or type == 'symlink'
      | each { |it|
        let value = if ($it.name | find -r '[[[:space:]]$()]' | is-empty) {
          $it.name + (char psep)
        } else {
          $'`($it.name)(char psep)`'
        }
        if $it.type == 'dir' {
          { value: $value, description: null }
        } else {
          { value: $value, description: ($it.name | path expand) }
        }
      }
      | where {$in.description == null or ($in.description | path type) == 'dir'}
    } catch {}
}

# Navigates up in the directory hierarchy
export def-env vd [
  steps?: int@vd_cmp # How many step to move up by
] {
  let span = (metadata $steps).span

  let steps = if $steps == null {
    1
  } else if $steps <= 0 {
    error make {
      msg: 'Invalid argument'
      label: {
        text: 'Steps must be a positive natural number'
        start: $span.start
        end: $span.end
      }
    }
  } else {
    $steps
  }

  cd ((1..$steps) | each {'..' + (char psep)} | str join)
}

def vd_cmp [] {
  pwd
  | str trim
  | path split
  | reverse
  | each -n { |it|
    {
      value: ($it.index)
      description: $it.item
    }
  }
  | skip 1
}

# Navigates back in the directory history
export def-env bd [
  steps?: int@bd_cmp # How many steps to move by
] {
  let span = (metadata $steps).span

  let length = ($env.BD_HISTORY | length)
  let steps = if $steps == null {
    if $length == 0 {
      return
    } else {
      $length - 1
    }
  } else if $steps <= 0 {
    error make {
      msg: 'Invalid argument'
      label: {
        text: 'Steps must be a positive natural number'
        start: $span.start
        end: $span.end
      }
    }
  } else {
    if $length == 0 {
      return
    } else {
      [0 ($length - $steps)] | math max
    }
  }

  let target = ($env.BD_HISTORY | get $steps)
  let-env BD_HISTORY = ($env.BD_HISTORY | take $steps)
  cd $target
}

def bd_cmp [] {
  $env.BD_HISTORY
  | reverse
  | each -n { |it|
    {
      value: ($it.index + 1)
      description: $it.item
    }
  }
}
