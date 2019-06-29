awk '{
  if ($0 ~ /<key>.+ Color<\/key>/) {
    color = $0
    gsub(/.*<key>/, "", color)
    gsub(/ Color<\/key>.*/, "", color)
    if (color ~ /^Ansi [0-9]$/) {
      gsub(" ", " 0", color)
    }
    colors[color] = color
  } else if ($0 ~ /(Alpha|Blue|Green|Red) Component/) {
    component = $0
    gsub(/.*<key>/, "", component)
    gsub(/ Component<\/key>.*/, "", component)
    getline
    value = $0
    gsub(/[^\.0-9]/, "", value)
    colors[color] = colors[color] ";" component ":" value
  }
} END { for (c in colors) { print colors[c] }}' ./gui/iterm2/graypalt.itermcolors \
| sort -k1,1 \
| awk -F';' '{
  print "Color: " $1
  for (i = 2; i <= NF; i++) {
    split($i, field, ":")
    component = field[1]
    value = field[2]
    byte = int(value * 255 + 0.5)
    print "  " component ": " value " (" byte ")"
    if (component == "Alpha") {
      a = byte
    } else if (component == "Blue") {
      b = byte
    } else if (component == "Green") {
      g = byte
    } else if (component == "Red") {
      r = byte
    }
  }
  printf("  Hex: #%02x%02x%02x%02x\n", r, g ,b , a)
}'
