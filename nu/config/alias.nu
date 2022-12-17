# Directories
alias l = ls -a
alias ll = ls -la
alias md = mkdir
alias rd = rmdir

# Neovim
alias vi = nvim

# Git
alias gb = git branch
alias gc = git commit -m
alias gca = git commit -a -m
alias gcm = git commit --amend --no-edit
alias gcl = git clone --recurse-submodules
alias gd = git diff
alias gds = git diff --staged
alias gf = git fetch --all --prune --jobs=10
alias gfm = (git fetch --all --prune --jobs=10; git merge origin/master)
alias gfr = (git fetch --all --prune --jobs=10; git rebase origin/maaster)
alias gl = git pull
alias gp = git push
alias gpf = git push --force-with-lease
alias gpp = git push --set-upstream origin (git symbolic-ref HEAD | split column '/' | transpose | last | get column1 | str trim)
alias gs = git stash
alias gsb = git status -sb
alias gsu = git submodule update --init --recursive
alias gt = git checkout
alias gtb = git checkout -b

# Show the tracking state of the current repository
def gbs [] {
  git branch --format "%(refname:short):%(upstream)"
  | lines
  | split column ':' branch upstream
  | each { |$it|
      if ($it.upstream | is-empty) {
        {
          branch: ((ansi blue) + $it.branch)
          upstream: 'Local'
        }
      } else {
        do -i { git rev-parse $it.upstream | complete }
        | if $in.exit_code == 0 {
            {
              branch: ((ansi green) + $it.branch)
              upstream: 'Tracked'
            }
          } else {
            {
              branch: ((ansi red) + $it.branch)
              upstream: 'Gone'
            }
          }
      }
    }
}

def gfr [branch?: string] {
  let branch = if ($branch | is-empty) {
    'origin/master'
  } else {
    'origin/' + $branch
  }
  git fetch --all --prune --jobs=10
  git rebase $branch
}

def gfm [branch?: string] {
  let branch = if ($branch | is-empty) {
    'origin/master'
  } else {
    'origin/' + $branch
  }
  git fetch --all --prune --jobs=10
  git merge $branch
}

def bdg [steps?: int@_bdg] {
  let span = (metadata $steps).span

  let steps = if $steps == null {
    1
  } else {
    $steps
  }

  if $steps < 1 {
    error make {
      msg: 'Invalid parameter'
      label: {
        text: 'Expected a positive natural number'
        start: $span.start
        end: $span.end
      }
    }
  }

  let repo = do -i {git rev-parse --absolute-git-dir | str trim}
  if ($repo | is-empty) {
    error make -u {
      msg: 'Not a git repository'
    }
  }

  let history = (
    [$repo, 'logs', 'HEAD']
    | path join
    | open
    | lines
    | parse -r '.*checkout: moving from.*[[:space:]](?<branch>.+)$'
    | reverse
    | skip 1
    | uniq
  )

  if ($history | length) < $steps {
    if $steps == 1 {
      error make -u {
        msg: 'No branch history'
      }
    } else {
      error make {
        msg: 'History is long enough'
        label: {
          text: 'Requested backtrack steps'
          start: $span.start
          end: $span.end
        }
      }
    }
  }

  let steps = $steps - 1
  git checkout ($history | get $steps | get branch)
}
def _bdg [] {
  let repo = do -i {git rev-parse --absolute-git-dir | str trim}
  if not ($repo | is-empty) {
    [$repo, 'logs', 'HEAD']
    | path join
    | open
    | lines
    | parse -r '.*checkout: moving from.*[[:space:]](?<branch>.+)$'
    | reverse
    | skip 1
    | uniq
    | each -n {|it| { value: ($it.index + 1), description: $it.item.branch }}
  }
}

# Python
module penv {
  # Loads virtualenv and overrides `exit` to mean `deactivate`
  export def penv [
    --local (-l): bool,  # Use a local virtual environment
    name?: string@cmp    # Name of the virtual environment
  ] {
    let span = (metadata $name).span
    if $name == null {
      if $local == false {
        error make -u {
          msg: 'Missing virtual environment name and not called as local'
        }
      }
    } else if $local == true {
      error make {
        msg: 'Invalid parameter combination'
        label: {
          text: 'Cannot name the environment when passing the `local` flag'
          start: $span.start
          end: $span.end
        }
      }
    }

    let $path = if $local {
      let path = ($env.PWD | path join '.venv')
      print $'Using: (ansi blue)($path)(ansi reset)'
      $path
    } else {
      [$env.HOME, 'code', 'python', 'env', $name] | path join
    }

    if ($path | path exists) {
      let path = ([$path, 'bin', 'activate.nu'] | path join)
      if ($path | path exists) {
        print -n ((ansi -e 'F') + (ansi -e 'J'))
        commandline $'overlay use ($path | into string)'
      } else {
        error make {
          msg: $'Path (ansi blue)($path)(ansi reset) invalid'
          label: {
            text: 'Path exists but has no activation script'
            start: $span.start
            end: $span.end
          }
        }
      }
    } else {
      let venv_check = (do -i { python3 -m virtualenv | complete | get exit_code })
      if ($venv_check !=  2) {
        error make -u {
          msg: $'Module (ansi yellow)virtualenv(ansi reset) was not found'
        }
      } else {
        python3 -m virtualenv $path

        let path_var = if ($nu.os-info.family == 'windows') {
            if ('Path' in (env).name) {
                'Path'
            } else {
                'PATH'
            }
        } else {
            'PATH'
        }

        let bin_path = ([$path, 'bin'] | path join)
        let-env VIRTUAL_ENV = $path
        let-env $path_var = ($env | get $path_var | prepend $bin_path)
        let activator = ([$bin_path, 'activate.nu'] | path join)

        python3 -m ensurepip
        python3 -m pip install --upgrade pip wheel setuptools

        'export alias exit = overlay hide activate' | save --raw --append $activator

        print $'Virtual environment ($name) ready to use'
        commandline $'overlay use ($activator)'
      }
    }
  }
  def cmp [] {
    ls ~/code/python/env
    | get name
    | each {|it| $it | path basename }
  }
}
use penv penv

module fd {
  # Navigates to a preconfigured location
  export def-env fd [base?: string@cmp, path?: string] {
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

  def cmp [] {
    open ~/.config/m-lima/fd/config
    | lines
    | split column ":" value description
  }
}
use fd fd

# VD
module vd {
  # Navigates up in the directory hierarchy
  export def-env vd [
    steps?: int@cmp # How many step to move up by
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

  def cmp [] {
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
}
use vd vd

# BD
module bd {
  export-env {
    let-env BD_HISTORY = []
  }

  # Navigates back in the directory history
  export def-env bd [
    steps?: int@cmp # How many steps to move by
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

  def cmp [] {
    $env.BD_HISTORY
    | reverse
    | each -n { |it|
      {
        value: ($it.index + 1)
        description: $it.item
      }
    }
  }
}
use bd bd

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
