return {
  {
    'ibhagwan/fzf-lua',
    event = 'VimEnter',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local fzf = require 'fzf-lua'

      fzf.setup {
        winopts = {
          height = 0.85,
          width = 0.80,
          row = 0.35,
          col = 0.50,
          border = 'rounded',
          fullscreen = false,
          preview = {
            layout = 'vertical',
            vertical = 'down:45%',
            scrollbar = true, -- Moved here from deprecated location
          },
        },
        fzf_opts = {
          ['--layout'] = 'reverse',
          ['--info'] = 'inline',
          ['--prompt'] = '❯ ',
        },
        previewers = {
          builtin = {
            syntax = true,
            extensions = {
              ['png'] = { 'viu' },
            },
          },
        },
        files = {
          prompt = 'Files❯ ',
          fd_opts = '--color=never --type f --hidden --follow --exclude .git',
        },
        grep = {
          prompt = 'Grep❯ ',
        },
      }

      local keymap = vim.keymap.set
      local desc = function(d)
        return { desc = d, noremap = true, silent = true }
      end

      keymap('n', '<leader>zsh', fzf.help_tags, desc '[S]earch [H]elp')
      keymap('n', '<leader>zsk', fzf.keymaps, desc '[S]earch [K]eymaps')
      keymap('n', '<leader>zsf', fzf.files, desc '[S]earch [F]iles')
      keymap('n', '<leader>zss', fzf.builtin, desc '[S]earch [S]elect FzfLua')
      keymap('n', '<leader>zsw', fzf.grep_cword, desc '[S]earch current [W]ord')
      keymap('n', '<leader>zsg', fzf.live_grep, desc '[S]earch by [G]rep')
      keymap('n', '<leader>zsd', fzf.diagnostics_workspace, desc '[S]earch [D]iagnostics')
      keymap('n', '<leader>zsr', fzf.resume, desc '[S]earch [R]esume')
      keymap('n', '<leader>zs.', fzf.oldfiles, desc '[S]earch Recent Files ("." for repeat)')
      keymap('n', '<leader>z<leader>', fzf.buffers, desc '[ ] Find existing buffers')

      keymap('n', '<leader>z/', function()
        fzf.blines {
          prompt = 'Buffer❯ ',
          winopts = {
            ---@diagnostic disable-next-line: missing-fields
            preview = {
              hidden = true,
            },
          },
        }
      end, desc '[/] Fuzzily search in current buffer')
      keymap('n', '<leader>zs/', function()
        fzf.live_grep_glob {
          prompt = 'Grep Open❯ ',
          grep_opts = '--files-with-matches --no-heading --line-number',
        }
      end, desc '[S]earch [/] in Open Files')

      keymap('n', '<leader>zsn', function()
        fzf.files { cwd = vim.fn.stdpath 'config', prompt = 'Neovim❯ ' }
      end, desc '[S]earch [N]eovim files')
    end,
  },
}
