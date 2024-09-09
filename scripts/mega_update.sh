#!/bin/sh

function prompt_question {
  printf "[34m${1}"
  if [[ "${2}" == "n" ]]; then
    printf " [37m[y/N][m "
  else
    printf " [37m[Y/n][m "
  fi

  read input
  case ${input} in
    [Yy] ) true ;;
    [Nn] ) false ;;
    * ) [[ "${2}" != "n" ]] ;;
  esac
}

function update_brew {
  if prompt_question "Update brew?"; then
    brew update
  fi

  outdated="$(brew outdated -v | grep -v '\[pinned')"
  if [ -n "${outdated}" ]; then
    echo '[33m::: Brew outdated output :::[m'
    echo "${outdated}"
    echo '[33m:::[m'

    if prompt_question "Update brew packages?"; then
      brew upgrade
    fi
  fi
}

function update_rust {
  if prompt_question "Update rust?"; then
    rustup update
  fi

  outdated="$(cargo install --list | grep '^[^ ]' | cut -d' ' -f1)"
  echo '[33m::: Cargo list output :::[m'
  echo "${outdated}"
  echo '[33m:::[m'

  if prompt_question "Update cargo crates?"; then
    cargo install ${outdated}
  fi
}

function update_zgen {
  if prompt_question "Update zgen?"; then
    zgen update
  fi
}

function update_npm {
  outdated="$(npm -g ls -p | grep node_modules | sed 's~.*/~~g')"
  echo '[33m::: NPM list output :::[m'
  echo "${outdated}"
  echo '[33m:::[m'

  if prompt_question "Update NPM?"; then
    npm -g i ${outdated}
  fi
}

function update_nvim {
  if prompt_question "Update VimPlug?"; then
    nvim -c 'PlugUpdate' -c 'PlugUpgrade' -c 'qa!'
  fi

  if prompt_question "Update Mason?"; then
    nvim --headless -c 'lua
    local registry = require("mason-registry")

    print("Updating registry..")
    registry.update(
      function(success)
        if not success then
          vim.schedule(
            function()
              print(" ERROR\n")
              vim.cmd("qa!")
            end
          )
          return
        end
        vim.schedule(
          function()
            print(" OK\n")
          end
        )

        local count = 0

        for _, pkg in ipairs(registry.get_installed_packages()) do
          count = count + 1
          pkg:check_new_version(
            function(new_available, version)
              if new_available then
                vim.schedule(
                  function()
                    print("Updating " .. pkg.name .. "\n")
                  end
                )
                pkg:install():on(
                  "closed",
                  function()
                    vim.schedule(
                      function()
                        print("Updated " .. pkg.name .. "\n")
                      end
                    )
                    count = count - 1
                  end
                )
              else
                count = count - 1
              end
            end
          )
        end

        vim.schedule(
          function()
            vim.wait(1000 * 60 * 15, function() return count == 0 end, 500)
            vim.cmd("qa!")
          end
        )
      end
    )'
  fi
}


if command -v brew &> /dev/null; then
  update_brew
fi

if command -v cargo &> /dev/null; then
  update_rust
fi

if command -v zgen &> /dev/null; then
  update_zgen
fi

if command -v npm &> /dev/null; then
  update_npm
fi

if command -v nvim &> /dev/null; then
  update_nvim
fi
