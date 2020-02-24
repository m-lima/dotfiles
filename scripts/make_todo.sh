if [ "${1}" ]; then
  output="${1}"
else
  output="./TODO.md"
fi

echo '# To Do

## Main
[ ] Todo
[ ] **Important**
[ ] ***Bug***
[x] Done
[x] ~~Will not do~~' > "${output}"
