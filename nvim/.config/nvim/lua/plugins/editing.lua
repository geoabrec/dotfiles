-- mini.nvim and plenary are also added by other files; vim.pack.add ignores repeats
vim.pack.add {
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
}

-- vim-tmux-navigator needs no setup call: it maps <C-h/j/k/l> across Neovim splits and tmux panes

require('guess-indent').setup {}

-- Text objects
require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

require('mini.surround').setup()

-- Harpoon
local harpoon = require 'harpoon'
harpoon:setup()

local function harpoon_picker()
  local conf = require('telescope.config').values

  local file_paths = {}
  for _, item in ipairs(harpoon:list().items) do
    table.insert(file_paths, item.value)
  end

  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Harpoon',
      finder = require('telescope.finders').new_table {
        results = file_paths,
      },
      previewer = conf.file_previewer {},
      sorter = conf.generic_sorter {},
    })
    :find()
end

vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'Add to Harpoon' })
vim.keymap.set('n', '<leader>e', function() harpoon:list():remove() end, { desc = 'Remove from Harpoon' })
vim.keymap.set('n', '<C-e>', harpoon_picker, { desc = 'Open Harpoon list' })
