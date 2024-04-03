export alias gb = git branch
export alias gc = git commit -m
export alias gca = git commit -a -m
export alias gcm = git commit --amend --no-edit
export alias gcl = git clone --recurse-submodules
export alias gd = git diff
export alias gds = git diff --staged
export alias gf = git fetch --all --prune --jobs=10
export alias gl = git pull
export alias glg = git log --stat
export alias gp = git push
export alias gpf = git push --force-with-lease
export alias gpp = git push --set-upstream origin (git symbolic-ref HEAD | split column '/' | transpose | last | get column1 | str trim)
export alias gs = git stash
export alias gsb = git status -sb
export alias gsu = git submodule update --init --recursive
export alias gt = git checkout
export alias gtb = git checkout -b
export alias gw = git switch
export alias gwb = git switch --create

# Show the tracking state of the current repository
export def gbs [] {
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

# Fetches all and rebases into the given upstream
export def gfr [
  upstream?: string@remotes # Upstream to rebase into
] {
  let upstream = if $upstream == null {
    'origin/master'
  } else {
    $upstream
  }
  git fetch --all --prune --jobs=10
  git rebase $upstream
}

# Fetches all and merges with the given upstream
export def gfm [
  upstream?: string@remotes # Upstream to merge with
] {
  let upstream = if $upstream == null {
    'origin/master'
  } else {
    $upstream
  }
  git fetch --all --prune --jobs=10
  git merge $upstream
}

def remotes [] {
  let repo = (do -i {git rev-parse --absolute-git-dir | str trim})
  if not ($repo | is-empty) {
    cd ([$repo, 'refs', 'remotes'] | path join)
    ls
    | get name
    | each {ls $in}
    | flatten
    | get name
  }
}

# Navigate back in the branch history
export def bdg [steps?: int@branch_history] {
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

  let repo = (do -i {git rev-parse --absolute-git-dir | str trim})
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

def branch_history [] {
  let repo = (do -i {git rev-parse --absolute-git-dir | str trim})
  if not ($repo | is-empty) {
    [$repo, 'logs', 'HEAD']
    | path join
    | open
    | lines
    | parse -r '.*checkout: moving from.*[[:space:]](?<branch>.+)$'
    | reverse
    | skip 1
    | uniq
    | enumerate
    | each {|it| { value: ($it.index + 1), description: $it.item.branch }}
  }
}

