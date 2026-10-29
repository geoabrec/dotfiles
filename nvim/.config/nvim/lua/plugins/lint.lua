vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

-- mason-tool-installer is used in lsp.lua for ensuring linters
-- are installed

-- ensure linting for markdown files
local lint = require 'lint'
lint.linters_by_ft = {
  markdown = { 'markdownlint' },
}

-- Create autocommand which carries out the actual linting on the specified events.
local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    if vim.bo.modifiable then lint.try_lint() end
  end,
})
