return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- Add LSP client info to statusline
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_lsp = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return ''
        end
        
        local client_names = {}
        local has_roslyn = false
        
        for _, client in pairs(clients) do
          table.insert(client_names, client.name)
          if client.name == 'roslyn' then
            has_roslyn = true
          end
        end
        
        local lsp_info = 'LSP: ' .. table.concat(client_names, ', ')
        
        -- Add Roslyn solution info if roslyn is active
        if has_roslyn then
          local sol = vim.g.roslyn_nvim_selected_solution
          if sol then
            local solution_name = vim.fn.fnamemodify(sol, ':t')  -- Get just the filename
            lsp_info = lsp_info .. ' [' .. solution_name .. ']'
          end
        end
        
        return lsp_info
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
