if grep '^size = 11.0 #FONT_SIZE_MARKER$' "${HOME}/.config/alacritty/transient.toml" &> /dev/null
then
  cat > "${HOME}/.config/alacritty/transient.toml" <<EOF
[font]
size = 14.5 #FONT_SIZE_MARKER
EOF
else
  cat > "${HOME}/.config/alacritty/transient.toml" <<EOF
[font]
size = 11.0 #FONT_SIZE_MARKER
EOF
fi

touch "${HOME}/.config/alacritty/alacritty.toml"
