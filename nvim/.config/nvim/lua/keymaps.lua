-- Keymaps that don't belong to a plugin. Plugin keymaps live next to the plugin in lua/plugins/.

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

vim.keymap.set({ 'n' }, '<leader>p', ':Ex <CR>', { desc = 'Open explorer' })

vim.keymap.set({ 'n' }, '<leader>o', ':Sex! <CR>', { desc = 'Open explorer in new window' })

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
