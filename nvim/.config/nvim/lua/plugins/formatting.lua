vim.pack.add { 'https://github.com/stevearc/conform.nvim' }

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local enabled_filetypes = {
      lua = true,
      python = true,
      c = true,
      cpp = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    else
      return nil
    end
  end,
  -- Filetypes without a formatter below fall back to the language server (Lua uses stylua this way)
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    python = { 'ruff_fix', 'ruff_organize_imports', 'ruff_format' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
