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
alias gd = git diff
alias gds = git diff --staged
alias gf = git fetch --all --prune --jobs=10
alias gfm = (git fetch --all --prune --jobs=10; git merge origin/master)
alias gfr = (git fetch --all --prune --jobs=10; git rebase origin/maaster)
alias gl = git pull
alias gp = git push
alias gpf = git push --force-with-lease
alias gpp = git push --set-upstream origin (git symbolic-ref HEAD | split words | last)
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
        do -i { git rev-parse $it.upstream }
        | complete
        | if $in.exit_code == 0 {
            {
              branch: ((ansi green) + $it.branch)
              upstream: 'Remote'
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

# Python

# Loads virtualenv and overrides `exit` to mean `deactivate`
def penv [
  --local (-l): bool,  # Use a local virtual environment
  name?: string@_penv  # Name of the virtual environment
] {
  let span = (metadata $name).span
  if $name == null {
    if $local == false {
      error make {
        msg: 'Missing virtual environment name and not called as local'
        label: {
          text: 'penv was called without any parameters'
          start: $span.start
          end: $span.end
        }
      }
    }
  } else if $local == true {
    error make {
      msg: 'Cannot name the environment when passing the `local` flag'
      label: {
        text: 'Environment name passed here'
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
        msg: $'Path (ansi blue)($path)(ansi reset) exists but has no activation script'
        label: {
          text: 'At this invocation'
          start: $span.start
          end: $span.end
        }
      }
    }
  } else {
    let venv_check = (do -i { python3 -m virtualenv | complete | get exit_code })
    if ($venv_check !=  2) {
      error make {
        msg: $'Module (ansi yellow)virtualenv(ansi reset) was not found'
        label: {
          text: 'At this invocation'
          start: $span.start
          end: $span.end
        }
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
def _penv [] {
  ls ~/code/python/env
  | get name
  | each {|it| $it | path basename }
}

# FD
def-env fd [path: string@_fd] {
  let span = (metadata $path).span
  let entry = (open ~/.config/m-lima/fd/config
    | lines
    | split column ':' cmd path
    | where cmd == $path
    | first
  )
  if $entry == null {
    error make {
      msg: 'Location not found'
      label: {
        text: 'Location name'
        start: $span.start
        end: $span.end
      }
    }
  } else {
    print -n ((ansi -e 'F') + (ansi -e 'J'))
    commandline $'cd ($entry.path)/'
  }
}
def _fd [] {
  open ~/.config/m-lima/fd/config
  | lines
  | split column ":" value description
}
