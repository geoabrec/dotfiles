vim.pack.add { 'https://github.com/danilo-augusto/vim-afterglow' }

local function make_transparent()
  local groups = {
    'Normal',
    'NormalNC',
    'NormalFloat',
    'SignColumn',
    'StatusLine',
    'StatusLineNC',
    'EndOfBuffer',
    'LineNr',
    'LineNrAbove',
    'LineNrBelow',
    'CursorLineNr',
    'FoldColumn',
  }
  for _, g in ipairs(groups) do
    local attrs = vim.api.nvim_get_hl(0, { name = g, link = false })
    attrs.bg, attrs.ctermbg = nil, nil
    vim.api.nvim_set_hl(0, g, attrs)
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'afterglow',
  callback = make_transparent,
})

vim.cmd.colorscheme 'afterglow'
