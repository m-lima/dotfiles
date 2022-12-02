# Nushell Environment Config File

# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = {
  let args = [((ansi yellow) + '⏾')]

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
let-env PROMPT_COMMAND_RIGHT = { simpalt r }

let-env SIMPALT_LONG = false

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = ''
let-env PROMPT_INDICATOR_VI_INSERT = ''
let-env PROMPT_INDICATOR_VI_NORMAL = ''
let-env PROMPT_MULTILINE_INDICATOR = { "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

let-env PATH = (~/code/dotfiles/nu/paths.sh | split row (char esep))

alias vi = nvim

alias gc = git commit
alias gc = git commit -m
alias gcam = git commit -a -m
alias gd = git diff
alias gds = git diff --staged
alias gl = git pull
alias gp = git push
alias gs = git status -sb

alias l = ls -a
alias md = mkdir
alias rd = rmdir
