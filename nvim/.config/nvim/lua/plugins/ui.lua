vim.pack.add {
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/wassimk/qf-formatter.nvim',
  'https://github.com/meanderingprogrammer/render-markdown.nvim',
}

-- Icons for Telescope, lualine, which-key and render-markdown
require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()

-- Statusline
---@param fg string colour of the mode block
local function mode_colors(fg)
  return {
    a = { bg = '#1a1a1a', fg = fg },
    b = { bg = '#2a2a2a', fg = '#e87d3e' },
    c = { bg = '#3a3a3a', fg = '#d6d6d6' },
  }
end

require('lualine').setup {
  options = {
    theme = {
      normal = mode_colors '#e87d3e',
      insert = mode_colors '#e5b567',
      visual = mode_colors '#6c99bb',
      command = mode_colors '#b05279',
      replace = mode_colors '#9e86c8',
      terminal = mode_colors '#6c99bb',
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

-- Keymap hints
require('which-key').setup {
  delay = 0,
  spec = {
    { '<leader>s', group = '[S]earch' },
    { 'gr', group = 'LSP Actions' },
  },
}

-- LSP progress in the bottom-right corner
require('fidget').setup {}

-- Git change markers in the sign column
require('gitsigns').setup {
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },
}

-- Quickfix list columns
require('qf-formatter').setup {
  filename_width = 32,
}

vim.api.nvim_set_hl(0, 'QfFormatterFilename', { fg = '#e87d3e' })
vim.api.nvim_set_hl(0, 'QfFormatterSeparator', { fg = '#d6d6d6' })
vim.api.nvim_set_hl(0, 'QfFormatterLineNr', { fg = '#d6d6d6' })

-- render-markdown needs no setup call: it starts itself on Markdown buffers
