export-env {
  if (which simpalt | is-empty) {
    print $'(ansi red)Prompt error:(ansi reset) `simpalt` not found. Make sure that it is in your (ansi yellow)PATH(ansi reset). Reverting to default prompt'
    print $'Binaries available for major platforms at (ansi blue)https://github.com/m-lima/simpalt-rs/releases(ansi reset)'
    {}
  } else {
    let simpalt_version = (simpalt v | str trim)
    if $simpalt_version != "0.2.0" {
      print $'(ansi yellow)Prompt info:(ansi reset) Expected version (ansi white)0.2.0(ansi reset) but `simpalt` is reporting version (ansi white)'($simpalt_version)'(ansi reset)'
      print $'Check (ansi blue)https://github.com/m-lima/simpalt-rs/releases(ansi reset) for the latest version'
    }

    let simpalt_host = if 'SIMPALT_HOST' in (env).name {
      $env.SIMPALT_HOST
    } else {
      ''
    }

    {
      PROMPT_COMMAND: {
        let args = [$env.SIMPALT_HOST]

        let args = if $env.LAST_EXIT_CODE == 0 {
          $args
        } else {
          $args | append '-e'
        }

        let args = if $env.SIMPALT_LONG {
          $args | append '-l'
        } else {
          $args
        }

        simpalt l $args
      }
      PROMPT_COMMAND_RIGHT: { simpalt r }
      SIMPALT_LONG: false
      SIMPALT_HOST: $simpalt_host
      VIRTUAL_ENV_DISABLE_PROMPT: true
      PROMPT_INDICATOR: ''
      PROMPT_INDICATOR_VI_INSERT: ''
      PROMPT_INDICATOR_VI_NORMAL: ''
      PROMPT_MULTILINE_INDICATOR: { "::: " }
    }
  } | load-env
}

# Allow toggling simpalt prompt length
export def-env toggle_simpalt [] {
  # Tip: add a keymap calling this command
  #
  # {
  #   name: toggle_simpalt
  #   modifier: Control
  #   keycode: Char_T
  #   mode: [ emacs vi_normal vi_insert ]
  #   event: {
  #     send: ExecuteHostCommand
  #     cmd: 'toggle_simpalt'
  #   }
  # }
  let-env SIMPALT_LONG = (not $env.SIMPALT_LONG)
  print -n ((ansi -e 'F') + (ansi -e 'J'))
}
