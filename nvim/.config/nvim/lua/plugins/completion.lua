vim.pack.add { { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.*' } }

require('blink.cmp').setup {
  keymap = {
    preset = 'default',
  },

  appearance = {
    nerd_font_variant = 'mono',
    use_nvim_cmp_as_default = true,
  },

  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },

  fuzzy = { implementation = 'lua' },

  signature = { enabled = true },
}

vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = '#252525', fg = '#e87d3e' })
vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { bg = '#252525', fg = '#e87d3e' })
vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { bg = '#252525', fg = '#d6d6d6' })
vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { bg = '#252525', fg = '#e87d3e' })
vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { bg = '#252525', fg = '#e87d3e' })
