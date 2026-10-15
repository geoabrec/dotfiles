vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

vim.keymap.set({ 'n' }, '<leader>o', ':Ex <CR>', { desc = 'Open explorer' })

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Non-recursive remaps

vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })

vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })

vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })

vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, silent = true })
