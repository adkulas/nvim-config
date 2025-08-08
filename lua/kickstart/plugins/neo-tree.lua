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
        -- Add Windows-specific settings
        use_default_mappings = false,
        default_component_configs = {
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
          },
        },
        window = {
          position = 'left',
          width = 30,
          mappings = {
            ['<space>'] = 'none', -- disable space toggling preview
            ['<cr>'] = 'open',
            ['<esc>'] = 'cancel', -- close preview or floating neo-tree window
            ['P'] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
            ['l'] = 'focus_preview',
            ['S'] = 'open_split',
            ['s'] = 'open_vsplit',
            ['t'] = 'open_tabnew',
            ['w'] = 'open_with_window_picker',
            ['C'] = 'close_node',
            ['z'] = 'close_all_nodes',
            ['a'] = { 
              'add',
              config = {
                show_path = "none" -- "none", "relative", "absolute"
              }
            },
            ['A'] = 'add_directory',
            ['d'] = 'delete',
            ['r'] = 'rename',
            ['y'] = 'copy_to_clipboard',
            ['x'] = 'cut_to_clipboard',
            ['p'] = 'paste_from_clipboard',
            ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like "add":
            ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like "add".
            ['q'] = 'close_window',
            ['R'] = 'refresh',
            ['?'] = 'show_help',
            ['<'] = 'prev_source',
            ['>'] = 'next_source',
            ['i'] = 'show_file_details',
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
            leave_dirs_open = false, -- `false` closes auto expanded dirs when switching files
          },
          hijack_netrw_behavior = 'open_default', -- replaces netrw
          use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
        },
        buffers = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false, -- `false` closes auto expanded dirs when switching files
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

    -- On Windows, normalize paths for comparison by using forward slashes
    -- and ensuring consistent casing
    local function normalize_path(path)
      if vim.fn.has('win32') == 1 then
        -- Convert backslashes to forward slashes and normalize case
        return path:gsub('\\', '/'):lower()
      else
        return path
      end
    end

    local cwd = vim.fn.getcwd()
    local normalized_file = normalize_path(file)
    local normalized_cwd = normalize_path(cwd)

    require('neo-tree.command').execute {
      action = 'focus',
      source = 'filesystem',
      position = 'left',
      reveal_file = file,
      -- Only force cwd change if file is truly outside cwd
      reveal_force_cwd = not vim.startswith(normalized_file, normalized_cwd),
    }
  end, { desc = 'Open Neo-tree and reveal file' })
}
