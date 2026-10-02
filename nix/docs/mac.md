# Finding which settings to change

```
$ fd . ~/Library/Preferences -t f -X ls -laht | head -10
```

# Interacting with the settings

```
$ defaults read com.apple.TV
$ defaults read com.apple.TV updateLevel
$ defaults read -g AppleICUNumberSymbols
$ deafults delete com.apple.TV updateLevel
```
