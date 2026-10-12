-- Leader must be set before any plugin defines a <leader> keymap
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.termguicolors = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.confirm = true

vim.o.hlsearch = false
vim.o.incsearch = true

vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
vim.o.guicursor = 'a:block-blinkwait500-blinkon500-blinkoff500'
vim.o.scrolloff = 10

vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.breakindent = true

vim.o.list = true
vim.opt.listchars = {
  tab = '▸ ',
  trail = '·',
}

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.swapfile = false
vim.o.undofile = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.ERROR } },
  virtual_lines = false,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}
