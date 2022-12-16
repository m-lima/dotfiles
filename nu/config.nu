# Nushell Config File

module completions {
  # Custom completions for external commands (those outside of Nushell)
  # Each completions has two parts: the form of the external command, including its flags and parameters
  # and a helper command that knows how to complete values for those flags and parameters
  #
  # This is a simplified version of completions for git branches and git remotes
  def "nu-complete git branches" [] {
    ^git branch | lines | each { |line| $line | str replace '[\*\+] ' '' | str trim }
  }

  def "nu-complete git remotes" [] {
    ^git remote | lines | each { |line| $line | str trim }
  }

  # Download objects and refs from another repository
  export extern "git fetch" [
    repository?: string@"nu-complete git remotes" # name of the repository to fetch
    branch?: string@"nu-complete git branches" # name of the branch to fetch
    --all                                         # Fetch all remotes
    --append(-a)                                  # Append ref names and object names to .git/FETCH_HEAD
    --atomic                                      # Use an atomic transaction to update local refs.
    --depth: int                                  # Limit fetching to n commits from the tip
    --deepen: int                                 # Limit fetching to n commits from the current shallow boundary
    --shallow-since: string                       # Deepen or shorten the history by date
    --shallow-exclude: string                     # Deepen or shorten the history by branch/tag
    --unshallow                                   # Fetch all available history
    --update-shallow                              # Update .git/shallow to accept new refs
    --negotiation-tip: string                     # Specify which commit/glob to report while fetching
    --negotiate-only                              # Do not fetch, only print common ancestors
    --dry-run                                     # Show what would be done
    --write-fetch-head                            # Write fetched refs in FETCH_HEAD (default)
    --no-write-fetch-head                         # Do not write FETCH_HEAD
    --force(-f)                                   # Always update the local branch
    --keep(-k)                                    # Keep dowloaded pack
    --multiple                                    # Allow several arguments to be specified
    --auto-maintenance                            # Run 'git maintenance run --auto' at the end (default)
    --no-auto-maintenance                         # Don't run 'git maintenance' at the end
    --auto-gc                                     # Run 'git maintenance run --auto' at the end (default)
    --no-auto-gc                                  # Don't run 'git maintenance' at the end
    --write-commit-graph                          # Write a commit-graph after fetching
    --no-write-commit-graph                       # Don't write a commit-graph after fetching
    --prefetch                                    # Place all refs into the refs/prefetch/ namespace
    --prune(-p)                                   # Remove obsolete remote-tracking references
    --prune-tags(-P)                              # Remove any local tags that do not exist on the remote
    --no-tags(-n)                                 # Disable automatic tag following
    --refmap: string                              # Use this refspec to map the refs to remote-tracking branches
    --tags(-t)                                    # Fetch all tags
    --recurse-submodules: string                  # Fetch new commits of populated submodules (yes/on-demand/no)
    --jobs(-j): int                               # Number of parallel children
    --no-recurse-submodules                       # Disable recursive fetching of submodules
    --set-upstream                                # Add upstream (tracking) reference
    --submodule-prefix: string                    # Prepend to paths printed in informative messages
    --upload-pack: string                         # Non-default path for remote command
    --quiet(-q)                                   # Silence internally used git commands
    --verbose(-v)                                 # Be verbose
    --progress                                    # Report progress on stderr
    --server-option(-o): string                   # Pass options for the server to handle
    --show-forced-updates                         # Check if a branch is force-updated
    --no-show-forced-updates                      # Don't check if a branch is force-updated
    -4                                            # Use IPv4 addresses, ignore IPv6 addresses
    -6                                            # Use IPv6 addresses, ignore IPv4 addresses
    --help                                        # Display the help message for this command
  ]

  # Check out git branches and files
  export extern "git checkout" [
    ...targets: string@"nu-complete git branches"   # name of the branch or files to checkout
    --conflict: string                              # conflict style (merge or diff3)
    --detach(-d)                                    # detach HEAD at named commit
    --force(-f)                                     # force checkout (throw away local modifications)
    --guess                                         # second guess 'git checkout <no-such-branch>' (default)
    --ignore-other-worktrees                        # do not check if another worktree is holding the given ref
    --ignore-skip-worktree-bits                     # do not limit pathspecs to sparse entries only
    --merge(-m)                                     # perform a 3-way merge with the new branch
    --orphan: string                                # new unparented branch
    --ours(-2)                                      # checkout our version for unmerged files
    --overlay                                       # use overlay mode (default)
    --overwrite-ignore                              # update ignored files (default)
    --patch(-p)                                     # select hunks interactively
    --pathspec-from-file: string                    # read pathspec from file
    --progress                                      # force progress reporting
    --quiet(-q)                                     # suppress progress reporting
    --recurse-submodules: string                    # control recursive updating of submodules
    --theirs(-3)                                    # checkout their version for unmerged files
    --track(-t)                                     # set upstream info for new branch
    -b: string                                      # create and checkout a new branch
    -B: string                                      # create/reset and checkout a branch
    -l                                              # create reflog for new branch
    --help                                          # Display the help message for this command
  ]

  # Push changes
  export extern "git push" [
    remote?: string@"nu-complete git remotes",      # the name of the remote
    ...refs: string@"nu-complete git branches"      # the branch / refspec
    --all                                           # push all refs
    --atomic                                        # request atomic transaction on remote side
    --delete(-d)                                    # delete refs
    --dry-run(-n)                                   # dry run
    --exec: string                                  # receive pack program
    --follow-tags                                   # push missing but relevant tags
    --force-with-lease                              # require old value of ref to be at this value
    --force(-f)                                     # force updates
    --ipv4(-4)                                      # use IPv4 addresses only
    --ipv6(-6)                                      # use IPv6 addresses only
    --mirror                                        # mirror all refs
    --no-verify                                     # bypass pre-push hook
    --porcelain                                     # machine-readable output
    --progress                                      # force progress reporting
    --prune                                         # prune locally removed refs
    --push-option(-o): string                       # option to transmit
    --quiet(-q)                                     # be more quiet
    --receive-pack: string                          # receive pack program
    --recurse-submodules: string                    # control recursive pushing of submodules
    --repo: string                                  # repository
    --set-upstream(-u)                              # set upstream for git pull/status
    --signed: string                                # GPG sign the push
    --tags                                          # push tags (can't be used with --all or --mirror)
    --thin                                          # use thin pack
    --verbose(-v)                                   # be more verbose
    --help                                          # Display the help message for this command
  ]
}

# Get just the extern definitions without the custom completion commands
use completions *

# The default config record. This is where much of your global configuration is setup.
let-env config = {
  cd: {
    abbreviations: false # set to true to allow you to do things like cd s/o/f and nushell expand it to cd some/other/folder
  }
  completions: {
    algorithm: "prefix"  # prefix, fuzzy
    case_sensitive: false # set to true to enable case-sensitive completions
    partial: true  # set this to false to prevent partial filling of the prompt
    quick: true  # set this to false to prevent auto-selecting completions when only one remains
    external: {
      completer: null # check 'carapace_completer' above to as example
      enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
      max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
    }
  }
  filesize: {
    format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
    metric: false # true => (KB, MB, GB), false => (KiB, MiB, GiB)
  }
  history: {
    file_format: "plaintext" # "sqlite" or "plaintext"
    max_size: 10000 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share the history between multiple sessions, else you have to close the session to persist history to file
  }
  ls: {
    clickable_links: true # true or false to enable or disable clickable links in the ls listing. your terminal has to support links.
    use_ls_colors: true
  }
  rm: {
    always_trash: false
  }
  table: {
    mode: light # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
    index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
    trim: {
      methodology: wrapping # wrapping or truncating
      wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
      # truncating_suffix: "..." # A suffix used by the 'truncating' methodology
    }
  }
  color_config: {
      # color for nushell primitives
      separator: white
      leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
      header: green_bold
      empty: blue
      bool: white
      int: white
      filesize: white
      duration: white
      date: white
      range: white
      float: white
      string: white
      nothing: white
      binary: white
      cellpath: white
      row_index: green_bold
      record: white
      list: white
      block: white
      hints: dark_gray

      # shapes are used to change the cli syntax highlighting
      shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
      shape_binary: purple_bold
      shape_bool: light_cyan
      shape_int: purple_bold
      shape_float: purple_bold
      shape_range: yellow_bold
      shape_internalcall: cyan_bold
      shape_external: cyan
      shape_externalarg: green_bold
      shape_literal: blue
      shape_operator: yellow
      shape_signature: green_bold
      shape_string: green
      shape_string_interpolation: cyan_bold
      shape_datetime: cyan_bold
      shape_list: cyan_bold
      shape_table: blue_bold
      shape_record: cyan_bold
      shape_block: blue_bold
      shape_filepath: cyan
      shape_directory: cyan
      shape_globpattern: cyan_bold
      shape_variable: purple
      shape_flag: blue_bold
      shape_custom: green
      shape_nothing: light_cyan
      shape_matching_brackets: { attr: u }
  }
  use_grid_icons: true
  footer_mode: "50" # always, never, number_of_rows, auto
  float_precision: 2
  # buffer_editor: "emacs" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
  use_ansi_coloring: true
  edit_mode: vi # emacs, vi
  shell_integration: true # enables terminal markers and a workaround to arrow keys stop working issue
  show_banner: false # true or false to enable or disable the banner
  render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.

  menus: [
      # Configuration for default nushell menus
      # Note the lack of souce parameter
      {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
        }
        style: {
            text: cyan
            selected_text: white
            description_text: yellow
        }
      }
      {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: cyan
            selected_text: white
            description_text: yellow
        }
      }
      {
        name: history_continuation_menu
        only_buffer_difference: false
        marker: "?> "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: cyan
            selected_text: white
            description_text: yellow
        }
      }
      {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: cyan
            selected_text: white
            description_text: yellow
        }
      }
      {
        name: commands_menu
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: columnar
            columns: 2
            col_padding: 2
        }
        style: {
            text: cyan
            selected_text: white
            description_text: yellow
        }
        source: { |buffer, position|
            let index = ( $buffer | str substring $',($position)' | str index-of -e ' ' ) + 1
            let last = ( $buffer | str substring $'($index),($position)' )
            $nu.scope.commands
            | where name =~ $last
            | each { |it|
                {
                  value: $it.name
                  description: $it.usage
                  span: {
                    start: $index
                    end: $position
                  }
                }
              }
        }
      }
      {
        name: vars_menu
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: cyan
            selected_text: white
            description_text: yellow
        }
        source: { |buffer, position|
            $nu.scope.vars
            | where name =~ $buffer
            | sort-by name
            | each { |it| {value: $it.name description: $it.type} }
        }
      }
      {
        name: prev_command_menu
        only_buffer_difference: false
        marker: "! "
        type: {
            layout: columnar
            columns: 4
            col_padding: 2
        }
        style: {
            text: cyan
            selected_text: white
            description_text: yellow
        }
        source: { |buffer, position|
            let index = ( $buffer | str substring $',($position)' | str index-of -e ' ' ) + 1
            let last = ( $buffer | str substring $'($index),($position)' )
            history
            | last
            | get command
            | parse -r "('[^']*'|\"(\\\\\"|[^\"])*\"|`[^`]*`|[^[[:space:]]]*)*"
            | get Capture1
            | uniq
            | where { |it| ($it | str length) > 3 and ($it =~ $last) }
            | each { |it|
                {
                  value: $it
                  span: {
                    start: $index
                    end: $position
                  }
                }
              }
        }
      }
  ]
  keybindings: [
    # Defaults
    #
    # Control ----------------------------------------------------
    # Esc             Escape                              Ok
    # Ctrl C          Ctrl C                              Ok
    # Ctrl D          Ctrl D                              Ok
    # Ctrl L          Clear screen                        Replaced
    # Ctrl R          History                             Ok
    # Ctrl O          Editor                              Removed
    #
    # Navigation -------------------------------------------------
    # Up              MenuUp, Up                          Ok
    # Down            MenuDown, Down                      Ok
    # Left            MenuLeft, Left                      Ok
    # Right           HistoryComplete, MenuRight, Right
    # Ctrl Left       MoveWordLeft
    # Ctrl Right      HistoryWordComplete, MoveWordRight
    # Home            MoveToLineStart                     Ok
    # Ctrl A          MoveToLineStart
    # End             HistoryComplete, MoveToLineEnd
    # Ctrl E          HistoryComplete, MoveToLineEnd      Replaced
    # Ctrl Home       MoveToStart                         Ok
    # Ctrl End        MoveToEnd                           Ok
    # Ctrl P          MenuUp, Up                          Replaced
    # Ctrl N          MenuDoen, Down                      Replaced
    #
    # Edit -------------------------------------------------------
    # Backspace       Backspace                           Ok
    # Delete          Delete                              Ok
    # Ctrl Backspace  BackspaceWord                       Ok
    # Ctrl Delete     DeleteWord                          Ok
    # Ctrl H          Backspace                           Replaced
    # Ctrl W          BackspaceWord                       Replaced
    #
    # Emacs [Control Navigation Edit] ----------------------------
    # Enter
    # Ctrl B
    # Ctrl F
    # Ctrl G
    # Ctrl Z
    # Ctrl Y
    # Ctrl W
    # Ctrl K
    # Ctrl U
    # Ctrl T
    # Alt Left                                            Copied
    # Alt Right                                           Copied
    # Alt B                                               Copied
    # Alt F                                               Copied
    # Alt Delete
    # Alt Backspace
    # Alt M
    # Alt D
    # Alt U
    # Alt L
    # Alt C
    #
    # Vi Normal [Control Navigation] -----------------------------
    # Backscpace
    # Delete
    #
    # Vi Insert [Control Navigation Edit] ------------------------

    # Removals
    {
      name: default_remove_ctrl_o
      modifier: Control
      keycode: Char_O
      mode: [ emacs vi_normal vi_insert ]
      event: null
    }

    # General editing
    {
      name: delete_current_word
      modifier: Control
      keycode: Char_W
      mode: [ emacs vi_normal vi_insert ]
      event: [
          { edit: MoveWordLeft }
          { edit: CutWordRightToNext }
      ]
    }
    {
      name: discard
      modifier: Control
      keycode: Char_U
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          {edit: Clear}
        ]
      }
    }
    {
      name: edit_command
      modifier: Control
      keycode: Char_E
      mode: [ emacs, vi_normal, vi_insert ]
      event: { send: OpenEditor }
    }
    {
      name: submit
      modifier: Control
      keycode: Char_Y
      mode: [ emacs, vi_normal, vi_insert ]
      event: [
        { send: HistoryHintComplete }
        { send: Submit }
      ]
    }

    # Move words around with SwapWord? Useful for docker!
    # {
    #   name: delete_current_word
    #   modifier: Control
    #   keycode: Char_X
    #   mode: [ emacs vi_normal vi_insert ]
    #   event: [
    #       { edit: SwapWords }
    #   ]
    # }


    # Navigation
    {
      name: move_word_left
      modifier: Alt
      keycode: Char_B
      mode: [ emacs vi_normal vi_insert ]
      event: { edit: MoveWordLeft }
    }
    {
      name: move_word_left
      modifier: Alt
      keycode: Left
      mode: [ emacs vi_normal vi_insert ]
      event: { edit: MoveWordLeft }
    }
    {
      name: move_word_right
      modifier: Alt
      keycode: Char_F
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          { send: HistoryHintWordComplete }
          { edit: MoveWordRight }
        ]
      }
    }
    {
      name: move_word_right
      modifier: Alt
      keycode: Right
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          { send: HistoryHintWordComplete }
          { edit: MoveWordRight }
        ]
      }
    }

    # Menus
    {
      name: completion_next
      modifier: None
      keycode: Tab
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          {
            send: Menu
            name: completion_menu
          }
          { send: MenuNext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: Shift
      keycode: BackTab
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          {
            send: Menu
            name: completion_menu
          }
          { send: MenuPrevious }
        ]
      }
    }
    {
      name: completion_next
      modifier: Control
      keycode: Char_N
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          {
            send: Menu
            name: completion_menu
          }
          { send: MenuNext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: Control
      keycode: Char_P
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          {
            send: Menu
            name: completion_menu
          }
          { send: MenuPrevious }
        ]
      }
    }
    {
      name: history_menu
      modifier: Control
      keycode: Char_R
      mode: [ emacs vi_normal vi_insert ]
      event: {
        send: Menu
        name: history_menu
      }
    }
    # {
    #   name: history_continuation_menu
    #   modifier: control|shift
    #   keycode: char_r
    #   mode: emacs
    #   event: { send: menu name: history_continuation_menu }
    # }
    {
      name: vars_menu
      modifier: Control
      keycode: Char_V
      mode: [ emacs vi_normal vi_insert ]
      event: {
        send: Menu
        name: vars_menu
      }
    }
    {
      name: commands_menu
      modifier: Control
      keycode: Char_S
      mode: [ emacs vi_normal vi_insert ]
      event: {
        send: Menu
        name: commands_menu
      }
    }
    {
      name: toggle_simpalt
      modifier: Control
      keycode: Char_T
      mode: [ emacs vi_normal vi_insert ]
      event: {
        send: ExecuteHostCommand
        cmd: 'let-env SIMPALT_LONG = (not $env.SIMPALT_LONG); print -n ((ansi -e 'F') + (ansi -e 'J'))'
      }
    }
    {
      name: prev_command_menu
      modifier: Control
      keycode: Char_A
      mode: [ emacs vi_normal vi_insert ]
      event: {
        send: Menu
        name: prev_command_menu
      }
    }

    # Vi style
    {
      name: vi_left
      modifier: Shift
      keycode: Char_H
      mode: vi_normal
      event: { edit: MoveToLineStart }
    }
    {
      name: vi_right
      modifier: Shift
      keycode: Char_L
      mode: vi_normal
      event: { edit: MoveToLineEnd }
    }
    {
      name: vi_left
      modifier: Control
      keycode: Char_H
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          { send: MenuLeft }
          { edit: MoveWordLeft }
        ]
      }
    }
    {
      name: vi_right
      modifier: Control
      keycode: Char_L
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          { send: MenuRight }
          { send: HistoryHintWordComplete }
          { edit: MoveWordRight }
        ]
      }
    }
    {
      name: vi_down
      modifier: Control
      keycode: Char_J
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          { send: MenuDown }
          { send: NextHistory }
        ]
      }
    }
    {
      name: vi_up
      modifier: Control
      keycode: Char_K
      mode: [ emacs vi_normal vi_insert ]
      event: {
        until: [
          { send: MenuUp }
          { send: PreviousHistory }
        ]
      }
    }




    # {
    #   name: prev_word
    #   modifier: control
    #   keycode: char_h
    #   mode: emacs
    #   event: {
    #     until: [
    #       { send: menuleft }
    #       { edit: cutfromlinestart }
    #     ]
    #   }
    # }
    # {
    #   name: next_line
    #   modifier: control
    #   keycode: char_j
    #   mode: emacs
    #   event: {
    #     until: [
    #       { send: menudown }
    #       { send: nexthistory }
    #       { edit: cutwordleft }
    #     ]
    #   }
    # }
    # {
    #   name: prev_line
    #   modifier: control
    #   keycode: char_k
    #   mode: emacs
    #   event: {
    #     until: [
    #       { send: menuup }
    #       { send: previoushistory }
    #       { edit: cutwordright }
    #     ]
    #   }
    # }
    # {
    #   name: next_word
    #   modifier: control
    #   keycode: char_l
    #   mode: emacs
    #   event: {
    #     until: [
    #       { send: menuright }
    #       { send: historyhintwordcomplete }
    #       { edit: cuttolineend }
    #     ]
    #   }
    # }
    #
    #
    # {
    #   name: history_menu
    #   modifier: control
    #   keycode: char_r
    #   mode: emacs
    #   event: { send: menu name: history_menu }
    # }
    # {
    #   name: history_continuation_menu
    #   modifier: control|shift
    #   keycode: char_r
    #   mode: emacs
    #   event: { send: menu name: history_continuation_menu }
    # }
    # {
    #   name: next_page
    #   modifier: control
    #   keycode: char_x
    #   mode: emacs
    #   event: { send: menupagenext }
    # }
    # {
    #   name: undo_or_previous_page
    #   modifier: control
    #   keycode: char_z
    #   mode: emacs
    #   event: {
    #     until: [
    #       { send: menupageprevious }
    #       { edit: undo }
    #     ]
    #    }
    # }
    # {
    #   name: redo
    #   modifier: control|shift
    #   keycode: char_z
    #   mode: emacs
    #   event: { edit: redo }
    # }
    # {
    #   name: yank
    #   modifier: control
    #   keycode: char_y
    #   mode: emacs
    #   event: {
    #     until: [
    #       {edit: pastecutbufferafter}
    #     ]
    #   }
    # }
    # # {
    # #   name: unix-line-discard
    # #   modifier: control
    # #   keycode: char_u
    # #   mode: [emacs, vi_normal, vi_insert]
    # #   event: {
    # #     until: [
    # #       {edit: cutfromlinestart}
    # #     ]
    # #   }
    # # }
    # # {
    # #   name: kill-line
    # #   modifier: control
    # #   keycode: char_k
    # #   mode: [emacs, vi_normal, vi_insert]
    # #   event: {
    # #     until: [
    # #       {edit: cuttolineend}
    # #     ]
    # #   }
    # # }
    # # Keybindings used to trigger the user defined menus
    # {
    #   name: commands_menu
    #   modifier: control
    #   keycode: char_t
    #   mode: [emacs, vi_normal, vi_insert]
    #   event: { send: menu name: commands_menu }
    # }
    # {
    #   name: commands_with_description
    #   modifier: control
    #   keycode: char_s
    #   mode: [emacs, vi_normal, vi_insert]
    #   event: { send: menu name: commands_with_description }
    # }
    # # {
    # #   name: last_command_parts
    # #   modifier: control
    # #   keycode: char_l
    # #   mode: [emacs, vi_normal, vi_insert]
    # #   event: { send: menu name: last_command_parts }
    # # }
  ]
}

