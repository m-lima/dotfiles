local base_gray = '#3a3a3a'

local middle = { bg = base_gray, fg = '#909090' }

return {
  grayalt = {
    normal = {
      a = {
        bg = '#444444',
        fg = '#949494',
        gui = 'bold',
      },
      b = middle,
      c = middle,
    },
    insert = {
      a = {
        bg = '#0a7aca',
        fg = '#b2b2b2',
        gui = 'bold',
      },
      b = middle,
      c = middle,
    },
    visual = {
      a = {
        bg = '#5e8759',
        fg = base_gray,
        gui = 'bold',
      },
      b = middle,
      c = middle,
    },
    replace = {
      a = {
        bg = '#0a7aca',
        fg = base_gray,
        gui = 'bold',
      },
      b = middle,
      c = middle,
    },
    terminal = {
      a = {
        bg = '#ffaf87',
        fg = base_gray,
        gui = 'bold',
      },
      b = middle,
      c = middle,
    },
    command = {
      a = {
        bg = '#874444',
        fg = '#949494',
        gui = 'bold',
      },
      b = middle,
      c = middle,
    },
    inactive = {
      a = {
        bg = '#444444',
        fg = '#949494',
        gui = 'bold',
      },
      b = middle,
      c = middle,
    },
  },
}

