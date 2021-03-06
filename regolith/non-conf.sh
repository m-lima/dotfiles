# Replace capslocak with escape
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"

# If change gnome fonts
gsettings set org.gnome.desktop.interface font-name 'Catarell 11'

# Manually set the background (allows for centered image, for example)
dconf write /org/gnome/desktop/background/picture-uri 'file:///path/to/file.png'
dconf write /org/gnome/desktop/background/primary-color "'#18212D'"
dconf write /org/gnome/desktop/background/picture-options "'centered'"

# Change the system-wide login screen
vi /usr/share/lightdm/lightdm-gtk-greeter.conf.d/02_regolith.conf

####################
# Misc actions
####################

# To check the current configuration for Xresources
xrdb -query

# To check the windows props
xprop

# Download NerdFonts and add to ~/.fonts
https://www.nerdfonts.com/font-downloads

# To chekc fonts
http://mathew-kurian.github.io/CharacterMap/
https://fontdrop.info/
