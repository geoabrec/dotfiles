vim.opt_local.linebreak = true

vim.keymap.set('n', '<leader>p', function()
  vim.cmd 'silent update'
  vim.system({ 'mdv', vim.api.nvim_buf_get_name(0) }, { text = true }, function(result)
    if result.code ~= 0 then vim.schedule(function() vim.notify(result.stderr, vim.log.levels.ERROR) end) end
  end)
end, { buffer = true, desc = '[P]review note in browser' })
