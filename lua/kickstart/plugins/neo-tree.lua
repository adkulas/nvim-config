-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    'antosha417/nvim-lsp-file-operations',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neo-tree/neo-tree.nvim', -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require('lsp-file-operations').setup()
      require('neo-tree').setup {
        close_if_last_window = true, -- closes Neo-tree if it's the last window open
        enable_git_status = true,
        enable_diagnostics = true,
        window = {
          position = 'left',
          width = 30,
          mappings = {
            ['<space>'] = 'none', -- disable space toggling preview
          },
        },
        filesystem = {
          filtered_items = {
            visible = true, -- show hidden files by default
            hide_dotfiles = false,
            hide_gitignored = true,
          },
          follow_current_file = {
            enabled = true,
          },
          hijack_netrw_behavior = 'open_default', -- replaces netrw
        },
        buffers = {
          follow_current_file = {
            enabled = true,
          },
        },
        git_status = {
          window = {
            position = 'float',
          },
        },
      }
    end,
  },
  vim.keymap.set('n', '<leader>e', function()
    local file = vim.fn.expand '%:p'
    if file == '' then
      file = vim.fn.getcwd()
    else
      local f = io.open(file, 'r')
      if f then
        f:close()
      else
        file = vim.fn.getcwd()
      end
    end

    local cwd = vim.fn.getcwd()
    local file_lower = file:lower()
    local cwd_lower = cwd:lower()

    require('neo-tree.command').execute {
      action = 'focus',
      source = 'filesystem',
      position = 'left',
      reveal_file = file,
      -- Only force cwd change if file is truly outside cwd (not just casing)
      reveal_force_cwd = not vim.startswith(file_lower, cwd_lower),
    }
  end, { desc = 'Open Neo-tree and reveal file' }),
}
