local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir, { follow = true }) do
  if (type == 'file' or type == 'link') and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('custom.plugins.' .. module)
  end
end

vim.pack.add { { src = 'https://github.com/danilo-augusto/vim-afterglow' } }

vim.pack.add { { src = 'https://github.com/rcarriga/nvim-notify' } }

vim.pack.add { { src = 'https://github.com/wassimk/qf-formatter.nvim' } }

vim.pack.add { { src = 'https://github.com/folke/noice.nvim' } }

vim.pack.add {
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-lualine/lualine.nvim',
}

vim.pack.add { { src = 'https://github.com/christoomey/vim-tmux-navigator' } }

vim.pack.add { { src = 'https://github.com/ThePrimeagen/vim-be-good' } }

vim.pack.add { { src = 'https://github.com/mbbill/undotree' } }

vim.pack.add { { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' } }
