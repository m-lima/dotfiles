import re
import subprocess
import os

from pathlib import Path

class Color:
    def __init__(self, r, g, b):
        self.r = r
        self.g = g
        self.b = b

    def __str__(self):
        if self.distance(Color(0, 0, 0)) < 0.5:
            return f'[48;2;{self.r};{self.g};{self.b};38;5;15m[{self.r}, {self.g}, {self.b}][m'
        else:
            return f'[48;2;{self.r};{self.g};{self.b};38;5;0m[{self.r}, {self.g}, {self.b}][m'

    def __repr__(self):
        if self.distance(Color(0, 0, 0)) < 0.5:
            return f'[48;2;{self.r};{self.g};{self.b};38;5;15m[{self.r}, {self.g}, {self.b}][m'
        else:
            return f'[48;2;{self.r};{self.g};{self.b};38;5;0m[{self.r}, {self.g}, {self.b}][m'

    def distance(self, input):
        import math
        delta_r = self.r - input.r
        delta_g = self.g - input.g
        delta_b = self.b - input.b
        return math.sqrt(delta_r * delta_r + delta_g * delta_g + delta_b * delta_b) / math.sqrt(255 * 255 * 3)

def color_from_str(input):
    def from_name(input):
        input = input.lower()
        if input in 'black': return Color(0, 0, 0)
        if input in 'darkred': return Color(128, 0, 0)
        if input in 'darkgreen': return Color(0, 128, 0)
        if input in ['darkyellow', 'brown']: return Color(128, 128, 0)
        if input in 'darkblue': return Color(0, 0, 128)
        if input in 'darkmagenta': return Color(128, 0, 128)
        if input in 'darkcyan': return Color(0, 128, 128)
        if input in ['lightgray', 'lightgrey', 'gray', 'grey']: return Color(192, 192, 192)
        if input in ['darkgray', 'darkgrey']: return Color(128, 128, 128)
        if input in ['red', 'lightred']: return Color(255, 0, 0)
        if input in ['green', 'lightgreen']: return Color(0, 255, 0)
        if input in ['yellow', 'lightyellow']: return Color(255, 255, 0)
        if input in ['blue', 'lightblue']: return Color(0, 0, 255)
        if input in ['magenta', 'lightmagenta']: return Color(255, 0, 255)
        if input in ['cyan', 'lightcyan']: return Color(0, 255, 255)
        if input in 'white': return Color(255, 255, 255)

        if input in 'seagreen': return Color(46, 139, 87)
        if input in 'grey40': return Color(108, 108, 108)

        return None

    def from_hex(input):
        input = int(input, 16)
        return Color((input >> 16) % 256, (input >> 8) % 256, input % 256)

    def from_cterm(input):
        input = int(input)
        if input == 0: return Color(0,0,0)
        if input == 1: return Color(128,0,0)
        if input == 2: return Color(0,128,0)
        if input == 3: return Color(128,128,0)
        if input == 4: return Color(0,0,128)
        if input == 5: return Color(128,0,128)
        if input == 6: return Color(0,128,128)
        if input == 7: return Color(192,192,192)
        if input == 8: return Color(128,128,128)
        if input == 9: return Color(255,0,0)
        if input == 10: return Color(0,255,0)
        if input == 11: return Color(255,255,0)
        if input == 12: return Color(0,0,255)
        if input == 13: return Color(255,0,255)
        if input == 14: return Color(0,255,255)
        if input == 15: return Color(255,255,255)
        if input == 16: return Color(0,0,0)
        if input == 17: return Color(0,0,95)
        if input == 18: return Color(0,0,135)
        if input == 19: return Color(0,0,175)
        if input == 20: return Color(0,0,215)
        if input == 21: return Color(0,0,255)
        if input == 22: return Color(0,95,0)
        if input == 23: return Color(0,95,95)
        if input == 24: return Color(0,95,135)
        if input == 25: return Color(0,95,175)
        if input == 26: return Color(0,95,215)
        if input == 27: return Color(0,95,255)
        if input == 28: return Color(0,135,0)
        if input == 29: return Color(0,135,95)
        if input == 30: return Color(0,135,135)
        if input == 31: return Color(0,135,175)
        if input == 32: return Color(0,135,215)
        if input == 33: return Color(0,135,255)
        if input == 34: return Color(0,175,0)
        if input == 35: return Color(0,175,95)
        if input == 36: return Color(0,175,135)
        if input == 37: return Color(0,175,175)
        if input == 38: return Color(0,175,215)
        if input == 39: return Color(0,175,255)
        if input == 40: return Color(0,215,0)
        if input == 41: return Color(0,215,95)
        if input == 42: return Color(0,215,135)
        if input == 43: return Color(0,215,175)
        if input == 44: return Color(0,215,215)
        if input == 45: return Color(0,215,255)
        if input == 46: return Color(0,255,0)
        if input == 47: return Color(0,255,95)
        if input == 48: return Color(0,255,135)
        if input == 49: return Color(0,255,175)
        if input == 50: return Color(0,255,215)
        if input == 51: return Color(0,255,255)
        if input == 52: return Color(95,0,0)
        if input == 53: return Color(95,0,95)
        if input == 54: return Color(95,0,135)
        if input == 55: return Color(95,0,175)
        if input == 56: return Color(95,0,215)
        if input == 57: return Color(95,0,255)
        if input == 58: return Color(95,95,0)
        if input == 59: return Color(95,95,95)
        if input == 60: return Color(95,95,135)
        if input == 61: return Color(95,95,175)
        if input == 62: return Color(95,95,215)
        if input == 63: return Color(95,95,255)
        if input == 64: return Color(95,135,0)
        if input == 65: return Color(95,135,95)
        if input == 66: return Color(95,135,135)
        if input == 67: return Color(95,135,175)
        if input == 68: return Color(95,135,215)
        if input == 69: return Color(95,135,255)
        if input == 70: return Color(95,175,0)
        if input == 71: return Color(95,175,95)
        if input == 72: return Color(95,175,135)
        if input == 73: return Color(95,175,175)
        if input == 74: return Color(95,175,215)
        if input == 75: return Color(95,175,255)
        if input == 76: return Color(95,215,0)
        if input == 77: return Color(95,215,95)
        if input == 78: return Color(95,215,135)
        if input == 79: return Color(95,215,175)
        if input == 80: return Color(95,215,215)
        if input == 81: return Color(95,215,255)
        if input == 82: return Color(95,255,0)
        if input == 83: return Color(95,255,95)
        if input == 84: return Color(95,255,135)
        if input == 85: return Color(95,255,175)
        if input == 86: return Color(95,255,215)
        if input == 87: return Color(95,255,255)
        if input == 88: return Color(135,0,0)
        if input == 89: return Color(135,0,95)
        if input == 90: return Color(135,0,135)
        if input == 91: return Color(135,0,175)
        if input == 92: return Color(135,0,215)
        if input == 93: return Color(135,0,255)
        if input == 94: return Color(135,95,0)
        if input == 95: return Color(135,95,95)
        if input == 96: return Color(135,95,135)
        if input == 97: return Color(135,95,175)
        if input == 98: return Color(135,95,215)
        if input == 99: return Color(135,95,255)
        if input == 100: return Color(135,135,0)
        if input == 101: return Color(135,135,95)
        if input == 102: return Color(135,135,135)
        if input == 103: return Color(135,135,175)
        if input == 104: return Color(135,135,215)
        if input == 105: return Color(135,135,255)
        if input == 106: return Color(135,175,0)
        if input == 107: return Color(135,175,95)
        if input == 108: return Color(135,175,135)
        if input == 109: return Color(135,175,175)
        if input == 110: return Color(135,175,215)
        if input == 111: return Color(135,175,255)
        if input == 112: return Color(135,215,0)
        if input == 113: return Color(135,215,95)
        if input == 114: return Color(135,215,135)
        if input == 115: return Color(135,215,175)
        if input == 116: return Color(135,215,215)
        if input == 117: return Color(135,215,255)
        if input == 118: return Color(135,255,0)
        if input == 119: return Color(135,255,95)
        if input == 120: return Color(135,255,135)
        if input == 121: return Color(135,255,175)
        if input == 122: return Color(135,255,215)
        if input == 123: return Color(135,255,255)
        if input == 124: return Color(175,0,0)
        if input == 125: return Color(175,0,95)
        if input == 126: return Color(175,0,135)
        if input == 127: return Color(175,0,175)
        if input == 128: return Color(175,0,215)
        if input == 129: return Color(175,0,255)
        if input == 130: return Color(175,95,0)
        if input == 131: return Color(175,95,95)
        if input == 132: return Color(175,95,135)
        if input == 133: return Color(175,95,175)
        if input == 134: return Color(175,95,215)
        if input == 135: return Color(175,95,255)
        if input == 136: return Color(175,135,0)
        if input == 137: return Color(175,135,95)
        if input == 138: return Color(175,135,135)
        if input == 139: return Color(175,135,175)
        if input == 140: return Color(175,135,215)
        if input == 141: return Color(175,135,255)
        if input == 142: return Color(175,175,0)
        if input == 143: return Color(175,175,95)
        if input == 144: return Color(175,175,135)
        if input == 145: return Color(175,175,175)
        if input == 146: return Color(175,175,215)
        if input == 147: return Color(175,175,255)
        if input == 148: return Color(175,215,0)
        if input == 149: return Color(175,215,95)
        if input == 150: return Color(175,215,135)
        if input == 151: return Color(175,215,175)
        if input == 152: return Color(175,215,215)
        if input == 153: return Color(175,215,255)
        if input == 154: return Color(175,255,0)
        if input == 155: return Color(175,255,95)
        if input == 156: return Color(175,255,135)
        if input == 157: return Color(175,255,175)
        if input == 158: return Color(175,255,215)
        if input == 159: return Color(175,255,255)
        if input == 160: return Color(215,0,0)
        if input == 161: return Color(215,0,95)
        if input == 162: return Color(215,0,135)
        if input == 163: return Color(215,0,175)
        if input == 164: return Color(215,0,215)
        if input == 165: return Color(215,0,255)
        if input == 166: return Color(215,95,0)
        if input == 167: return Color(215,95,95)
        if input == 168: return Color(215,95,135)
        if input == 169: return Color(215,95,175)
        if input == 170: return Color(215,95,215)
        if input == 171: return Color(215,95,255)
        if input == 172: return Color(215,135,0)
        if input == 173: return Color(215,135,95)
        if input == 174: return Color(215,135,135)
        if input == 175: return Color(215,135,175)
        if input == 176: return Color(215,135,215)
        if input == 177: return Color(215,135,255)
        if input == 178: return Color(215,175,0)
        if input == 179: return Color(215,175,95)
        if input == 180: return Color(215,175,135)
        if input == 181: return Color(215,175,175)
        if input == 182: return Color(215,175,215)
        if input == 183: return Color(215,175,255)
        if input == 184: return Color(215,215,0)
        if input == 185: return Color(215,215,95)
        if input == 186: return Color(215,215,135)
        if input == 187: return Color(215,215,175)
        if input == 188: return Color(215,215,215)
        if input == 189: return Color(215,215,255)
        if input == 190: return Color(215,255,0)
        if input == 191: return Color(215,255,95)
        if input == 192: return Color(215,255,135)
        if input == 193: return Color(215,255,175)
        if input == 194: return Color(215,255,215)
        if input == 195: return Color(215,255,255)
        if input == 196: return Color(255,0,0)
        if input == 197: return Color(255,0,95)
        if input == 198: return Color(255,0,135)
        if input == 199: return Color(255,0,175)
        if input == 200: return Color(255,0,215)
        if input == 201: return Color(255,0,255)
        if input == 202: return Color(255,95,0)
        if input == 203: return Color(255,95,95)
        if input == 204: return Color(255,95,135)
        if input == 205: return Color(255,95,175)
        if input == 206: return Color(255,95,215)
        if input == 207: return Color(255,95,255)
        if input == 208: return Color(255,135,0)
        if input == 209: return Color(255,135,95)
        if input == 210: return Color(255,135,135)
        if input == 211: return Color(255,135,175)
        if input == 212: return Color(255,135,215)
        if input == 213: return Color(255,135,255)
        if input == 214: return Color(255,175,0)
        if input == 215: return Color(255,175,95)
        if input == 216: return Color(255,175,135)
        if input == 217: return Color(255,175,175)
        if input == 218: return Color(255,175,215)
        if input == 219: return Color(255,175,255)
        if input == 220: return Color(255,215,0)
        if input == 221: return Color(255,215,95)
        if input == 222: return Color(255,215,135)
        if input == 223: return Color(255,215,175)
        if input == 224: return Color(255,215,215)
        if input == 225: return Color(255,215,255)
        if input == 226: return Color(255,255,0)
        if input == 227: return Color(255,255,95)
        if input == 228: return Color(255,255,135)
        if input == 229: return Color(255,255,175)
        if input == 230: return Color(255,255,215)
        if input == 231: return Color(255,255,255)
        if input == 232: return Color(8,8,8)
        if input == 233: return Color(18,18,18)
        if input == 234: return Color(28,28,28)
        if input == 235: return Color(38,38,38)
        if input == 236: return Color(48,48,48)
        if input == 237: return Color(58,58,58)
        if input == 238: return Color(68,68,68)
        if input == 239: return Color(78,78,78)
        if input == 240: return Color(88,88,88)
        if input == 241: return Color(98,98,98)
        if input == 242: return Color(108,108,108)
        if input == 243: return Color(118,118,118)
        if input == 244: return Color(128,128,128)
        if input == 245: return Color(138,138,138)
        if input == 246: return Color(148,148,148)
        if input == 247: return Color(158,158,158)
        if input == 248: return Color(168,168,168)
        if input == 249: return Color(178,178,178)
        if input == 250: return Color(188,188,188)
        if input == 251: return Color(198,198,198)
        if input == 252: return Color(208,208,208)
        if input == 253: return Color(218,218,218)
        if input == 254: return Color(228,228,228)
        if input == 255: return Color(238,238,238)
        return None

    def from_str_inner(input):
        if len(input) == 7 and input[0] == '#': return from_hex(input[1:])
        if input.isdigit(): return from_cterm(input)
        return from_name(input)

    color = from_str_inner(input)
    if color:
        return color
    else:
        raise Exception(f'Unrecognized color: {input}')


def load_highlights():
    rc = os.path.join(Path.home(), '.config', 'nvim', 'init.vim')
    return subprocess.check_output(['nvim', '-es', '-u', rc, '+set nornu', '+set nonu', '+redir @">', '+hi', '+redir END', '+put', '+%print']).decode().split('\n')

def clean_output(input):
    double_space = r'\s\s+'
    output = []
    for line in input:
        if line.isspace():
            continue
        if line.startswith(' '):
            last = output.pop()
            last += ' ' + re.sub(double_space, ' ', line.strip())
            output.append(last)
        else:
            output.append(re.sub(double_space, ' ', line.strip()))
    return output

def get_colors(input):
    regex_guifg = r'.+guifg=([^\s]+).*'
    regex_ctermfg = r'.+ctermfg=([^\s]+).*'
    regex_guibg = r'.+guibg=([^\s]+).*'
    regex_ctermbg = r'.+ctermbg=([^\s]+).*'
    regex_name = r'([^\s]+).*'

    output= []

    def get_pair(line, regex_gui, regex_cterm):
        gui = re.match(regex_gui, line)
        if gui and gui[1] != 'bg':
            cterm = re.match(regex_cterm, line)
            if cterm and cterm[1] != 'fg':
                return (color_from_str(gui[1]), color_from_str(cterm[1]))
        return None

    for line in input:
        fg = get_pair(line, regex_guifg, regex_ctermfg)
        bg = get_pair(line, regex_guibg, regex_ctermbg)

        if fg or bg:
            name = re.match(regex_name, line)
            if name:
                output.append((name[1], (fg, bg)))
            else:
                raise 'Could not extract name for: ' + line

    return output

result = load_highlights()
result = clean_output(result)
result = get_colors(result)
for r in result:
    distance_fg = 0
    distance_bg = 0

    if r[1][0]:
        distance_fg = r[1][0][0].distance(r[1][0][1])
    if r[1][1]:
        distance_bg = r[1][1][0].distance(r[1][1][1])

    if distance_fg > 0.1:
        print(r[0])
        print(f'    fg = {r[1][0]} = {distance_fg}')
    if distance_bg > 0.1:
        if distance_fg <= 0.1:
            print(r[0])
        print(f'    bg = {r[1][1]} = {distance_bg}')
