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
          ['--prompt'] = '> ',
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
          prompt = 'Files> ',
          fd_opts = '--color=never --type f --hidden --follow --exclude .git',
        },
        grep = {
          prompt = 'Grep> ',
          input_prompt = 'Grep For❯ ',
          multiprocess = true,           -- run command in a separate process
          git_icons = true,             -- show git icons?
          file_icons = true,            -- show file icons?
          color_icons = true,           -- colorize file|git icons
          -- live_grep_glob options
          glob_flag = "--iglob",        -- for case insensitive globs use '--iglob'
          glob_separator = "%s%-%-",    -- query separator pattern (lua): ' --'
          -- Debounce settings for live grep
          debounce = 500,               -- debounce live_grep in milliseconds (500ms = 0.5 seconds)
          -- You can also set cmd_delay for additional delay
          cmd_delay = 100,              -- delay before executing the grep command (100ms)
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
      keymap('n', '<leader>zsg', function()
        fzf.live_grep {
          debounce = 500,  -- 500ms delay after stopping typing
          cmd_delay = 100, -- 100ms delay before executing command
        }
      end, desc '[S]earch by [G]rep')
      keymap('n', '<leader>zsd', fzf.diagnostics_workspace, desc '[S]earch [D]iagnostics')
      keymap('n', '<leader>zsr', fzf.resume, desc '[S]earch [R]esume')
      keymap('n', '<leader>zs.', fzf.oldfiles, desc '[S]earch Recent Files ("." for repeat)')
      keymap('n', '<leader>z<leader>', fzf.buffers, desc '[ ] Find existing buffers')

      keymap('n', '<leader>z/', function()
        fzf.blines {
          prompt = 'Buffer> ',
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
          prompt = 'Grep Open> ',
          grep_opts = '--files-with-matches --no-heading --line-number',
          debounce = 500,  -- 500ms delay after stopping typing
          cmd_delay = 100, -- 100ms delay before executing command
        }
      end, desc '[S]earch [/] in Open Files')

      keymap('n', '<leader>zsn', function()
        fzf.files { cwd = vim.fn.stdpath 'config', prompt = 'Neovim> ' }
      end, desc '[S]earch [N]eovim files')

      -- Custom picker for .slnf files with Roslyn LSP attachment
      keymap('n', '<leader>zsl', function()
        fzf.files {
          prompt = 'Solution Filters> ',
          fd_opts = '--color=never --type f --extension slnf --hidden --follow',
          cwd = vim.fn.getcwd(), -- Search from current working directory and all subdirectories
          actions = {
            ['default'] = function(selected, opts)
              if selected and #selected > 0 then
                local slnf_file = selected[1]
                -- Remove any leading path indicators that fzf might add
                slnf_file = slnf_file:gsub('^%s*', ''):gsub('%s*$', '')
                
                -- Get the full path
                local full_path = vim.fn.fnamemodify(slnf_file, ':p')
                
                -- Check if Roslyn command is available
                if vim.fn.exists(':Roslyn') == 0 then
                  vim.notify('Roslyn command not available. Make sure roslyn.nvim is loaded.', vim.log.levels.ERROR)
                  return
                end
                
                -- Execute the Roslyn target command with proper error handling
                local success, err = pcall(function()
                  vim.cmd('Roslyn target ' .. vim.fn.shellescape(full_path))
                end)
                
                if success then
                  vim.notify('Roslyn LSP attached to: ' .. vim.fn.fnamemodify(full_path, ':t'), vim.log.levels.INFO)
                else
                  vim.notify('Failed to attach Roslyn LSP: ' .. tostring(err), vim.log.levels.ERROR)
                end
              end
            end,
            ['ctrl-v'] = function(selected, opts)
              if selected and #selected > 0 then
                local slnf_file = selected[1]:gsub('^%s*', ''):gsub('%s*$', '')
                local full_path = vim.fn.fnamemodify(slnf_file, ':p')
                
                -- Open the .slnf file in a vertical split to inspect it
                vim.cmd('vsplit ' .. vim.fn.shellescape(full_path))
              end
            end,
          },
        }
      end, desc '[S]earch Solution [L]anguage files (.slnf) and attach LSP')

      -- Alternative picker that shows more details about .slnf files
      keymap('n', '<leader>zsL', function()
        local function get_slnf_files()
          -- Search from current working directory and all subdirectories
          local cwd = vim.fn.getcwd()
          local cmd = string.format('fd -t f -e slnf --hidden --follow . %s 2>/dev/null || find %s -name "*.slnf" -type f 2>/dev/null', 
                                   vim.fn.shellescape(cwd), vim.fn.shellescape(cwd))
          
          local handle = io.popen(cmd)
          if not handle then
            vim.notify('Could not search for .slnf files in current directory tree', vim.log.levels.WARN)
            return {}
          end
          
          local result = handle:read('*a')
          handle:close()
          
          local files = {}
          for file in result:gmatch('[^\r\n]+') do
            if file and file ~= '' then
              local full_path = vim.fn.fnamemodify(file, ':p')
              local relative_path = vim.fn.fnamemodify(file, ':.')
              local dir = vim.fn.fnamemodify(file, ':h')
              local name = vim.fn.fnamemodify(file, ':t')
              
              table.insert(files, {
                display = string.format('%-30s  %s', name, dir),
                value = relative_path,
                full_path = full_path,
              })
            end
          end
          
          return files
        end

        local slnf_files = get_slnf_files()
        
        if #slnf_files == 0 then
          vim.notify('No .slnf files found in current directory tree', vim.log.levels.WARN)
          return
        end

        fzf.fzf_exec(function(cb)
          for _, file in ipairs(slnf_files) do
            cb(file.display, function()
              return file
            end)
          end
          cb() -- signal end of data
        end, {
          prompt = 'Solution Filters (detailed)> ',
          actions = {
            ['default'] = function(selected, opts)
              if selected and #selected > 0 then
                local file_data = selected[1]()
                if file_data then
                  -- Check if Roslyn command is available
                  if vim.fn.exists(':Roslyn') == 0 then
                    vim.notify('Roslyn command not available. Make sure roslyn.nvim is loaded.', vim.log.levels.ERROR)
                    return
                  end
                  
                  -- Execute the Roslyn target command with proper error handling
                  local success, err = pcall(function()
                    vim.cmd('Roslyn target ' .. vim.fn.shellescape(file_data.full_path))
                  end)
                  
                  if success then
                    vim.notify('Roslyn LSP attached to: ' .. vim.fn.fnamemodify(file_data.full_path, ':t'), vim.log.levels.INFO)
                  else
                    vim.notify('Failed to attach Roslyn LSP: ' .. tostring(err), vim.log.levels.ERROR)
                  end
                end
              end
            end,
            ['ctrl-v'] = function(selected, opts)
              if selected and #selected > 0 then
                local file_data = selected[1]()
                if file_data then
                  vim.cmd('vsplit ' .. vim.fn.shellescape(file_data.full_path))
                end
              end
            end,
          },
        })
      end, desc '[S]earch Solution [L]anguage files (detailed view) and attach LSP')
    end,
  },
}
