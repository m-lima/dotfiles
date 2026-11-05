{
  reset = "[m";
  style = {
    bold = {
      set = "[1m";
      reset = "[22m";
    };
    dim = {
      set = "[2m";
      reset = "[22m";
    };
    italic = {
      set = "[3m";
      reset = "[23m";
    };
    underline = {
      set = "[4m";
      reset = "[24m";
    };
    doubleUnderline = {
      set = "[21m";
      reset = "[24m";
    };
    blink = {
      set = "[5m";
      reset = "[25m";
    };
    fastBlink = {
      set = "[6m";
      reset = "[25m";
    };
    reverse = {
      set = "[7m";
      reset = "[27m";
    };
    hide = {
      set = "[8m";
      reset = "[28m";
    };
    strike = {
      set = "[9m";
      reset = "[29m";
    };
  };
  fg = {
    red = "[31m";
    green = "[32m";
    yellow = "[33m";
    blue = "[34m";
    magenta = "[35m";
    cyan = "[36m";
    white = "[37m";
    brightRed = "[91m";
    brightGreen = "[92m";
    brightYellow = "[93m";
    brightBlue = "[94m";
    brightMagenta = "[95m";
    brightCyan = "[96m";
    brightWhite = "[97m";
    vga = color: "[38;5;${color}m";
    rgb =
      r: g: b:
      "[38;2;${r};${g};${b}m";
    reset = "[39m";
  };
  bg = {
    black = "[40m";
    red = "[41m";
    green = "[42m";
    yellow = "[43m";
    blue = "[44m";
    magenta = "[45m";
    cyan = "[46m";
    white = "[47m";
    brightRed = "[101m";
    brightGreen = "[102m";
    brightYellow = "[103m";
    brightBlue = "[104m";
    brightMagenta = "[105m";
    brightCyan = "[106m";
    brightWhite = "[107m";
    vga = color: "[48;5;${color}m";
    rgb =
      r: g: b:
      "[48;2;${r};${g};${b}m";
    reset = "[49m";
  };
}
