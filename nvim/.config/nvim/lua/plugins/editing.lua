vim.pack.add {
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/NMAC427/guess-indent.nvim',
  'https://github.com/christoomey/vim-tmux-navigator',
  'https://github.com/tpope/vim-obsession',
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
}

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

vim.keymap.set('n', '<C-m>', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<C-t>', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<C-n>', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<C-p>', function() harpoon:list():select(4) end)
