vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name ~= 'nvim-treesitter' then return end
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end

    if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
    vim.cmd 'TSUpdate'
  end,
})

vim.pack.add { { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } }

local treesitter = require 'nvim-treesitter'

treesitter.install { 'bash', 'c', 'cpp', 'diff', 'latex', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query', 'vim', 'vimdoc', 'json' }

---@param buf integer
---@param language string
local function attach(buf, language)
  if not vim.treesitter.language.add(language) then return end
  vim.treesitter.start(buf, language)

  if vim.treesitter.query.get(language, 'indents') then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local available_parsers = treesitter.get_available()

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
  callback = function(args)
    local buf = args.buf
    local language = vim.treesitter.language.get_lang(args.match)
    if not language then return end

    local installed = vim.tbl_contains(treesitter.get_installed 'parsers', language)
    if not installed and vim.tbl_contains(available_parsers, language) then
      treesitter.install(language):await(function() attach(buf, language) end)
    else
      attach(buf, language)
    end
  end,
})
