local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      if entry.source.name == 'nvim_lsp' then
        vim_item.menu = ''
      elseif entry.source.name == 'cmp_tabnine' then
        vim_item.kind = 'TabNine'
      elseif entry.source.name == 'nvim_lsp_signature_help' then
        vim_item.kind = 'Param'
      elseif entry.source.name == 'buffer' then
        vim_item.kind = 'Buffer'
      elseif entry.source.name == 'cmdline' then
        vim_item.kind = 'Vim'
      elseif entry.source.name == 'tmux' then
        vim_item.kind = 'Tmux'
        vim_item.menu = nil
      end

      return vim_item
    end
  },
  mapping = {
    ['<C-k>'] = cmp.mapping.scroll_docs(-4),
    ['<C-j>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    }),
    ['<Tab>'] = cmp.mapping(
      function(fallback)
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end,
      { 'i', 's' }
    ),
    ['<S-Tab>'] = cmp.mapping(
      function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end,
      { 'i', 's' }
    ),
  },
  sources = {
    { name = 'nvim_lsp_signature_help', keyword_lenght = 0 },
    { name = 'cmp_tabnine' },
    { name = 'nvim_lsp' },
    { name = 'buffer', max_item_count = 5 },
    { name = 'path' },
    { name = 'tmux', max_item_count = 5 },
  }
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
    { name = 'tmux', max_item_count = 5 },
  },
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'path' },
    { name = 'cmdline' },
    { name = 'tmux', max_item_count = 5 },
  },
})
