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
