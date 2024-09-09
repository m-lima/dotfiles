# Compares gui and cterm colors and gives a distance score
root=$(dirname $(dirname "$0"))

highlights=`nvim -es -u "${root}/vim/init.vim" +'redir @">' +'hi' +'redir END' +put +%print`
fg=`grep guifg <<<"$highlights" | grep ctermfg`
bg=`grep guibg <<<"$highlights" | grep ctermbg`
echo $bg
