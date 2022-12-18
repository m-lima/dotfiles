# TODO: Write a little "plugin-manager"?

# Modules
use plugins/git.nu *
use plugins/nali.nu *
use plugins/penv.nu *
# use plugins/clipwd.mac.nu *
use ~/code/rust/simpalt-rs/simpalt.nu *

module completer {
  export def dispatch [args] {
    if $args.0 == 'fd' {
      if ($args | length) == 3 {
        fd $args.1 $args.2
      } else {
        []
      }
    }
  }

  def fd [base: string, path?: string] {
    let entry = try {
      open ~/.config/m-lima/fd/config
      | lines
      | split column ':' cmd path
      | where cmd == $base
      | first
    } catch {
      return
    }

    let path = if $path == null { '' } else { $path };

    try {
      cd $entry.path
      ls $'($path)*'
      | where type == 'dir' or type == 'symlink'
      | each { |it|
        if $it.type == 'dir' {
          { value: ($it.name + (char psep)), description: null }
        } else {
          { value: ($it.name + (char psep)), description: ($it.name | path expand) }
        }
      }
      | where {$in.description == null or ($in.description | path type) == 'dir'}
    } catch {}
  }
}

module hook {
  export def env_change [] {
    {
      PWD: {
        condition: {|before, after| $before != null}
        code: {|before, after| let-env BD_HISTORY = ($env.BD_HISTORY | append $before)}
      }
    }
  }
}
