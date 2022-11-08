if grep '^  size: 11.0 #FONT_SIZE_MARKER$' "${HOME}/.config/m-lima/alacritty/transient.yml" &> /dev/null
then
  cat > "${HOME}/.config/m-lima/alacritty/transient.yml" <<EOF
font:
  size: 14.5 #FONT_SIZE_MARKER
EOF
else
  cat > "${HOME}/.config/m-lima/alacritty/transient.yml" <<EOF
font:
  size: 11.0 #FONT_SIZE_MARKER
EOF
fi

touch "${HOME}/.config/alacritty/alacritty.yml"
