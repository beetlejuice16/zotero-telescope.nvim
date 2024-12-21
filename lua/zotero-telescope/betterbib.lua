local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local config = require('telescope.config').values
local log = require('plenary.log'):new()
local curl = require('plenary.curl')
local utils = require('telescope.previewers.utils')
log.level = 'debug'
local M = {}

---@param base_url? string Default: "http://localhost:23119/better-bibtex/library?/1/library.json" see better bib [docs](https://retorque.re/zotero-better-bibtex/exporting/pull/index.html)
---@return table
M.get_zotero_data_betterbib = function(base_url)
  local base_url = base_url or 'http://localhost:23119/better-bibtex/library?/1/library.json'
  local api_endpoint = base_url
  local response = curl.get(api_endpoint)
  local data = response.body
  local parsed_data = vim.json.decode(data, { array = true })
  log.debug(parsed_data)
  return parsed_data
end

M.show_zotero_bib = function(opts)
  pickers
    .new(opts, {
      finder = finders.new_table({
        results = M.get_zotero_data_betterbib(),
        entry_maker = function(entry)
          local display = entry.title
          local authors = entry.author

          if authors then
            if next(authors) then
              if authors[1].family then
                display = authors[1].family .. ', ' .. authors[1].given .. ' - ' .. display
              end
              if authors[1].literal then
                display = authors[1].literal .. ' - ' .. display
              end
            end
          end

          -- In case we want to extend the ordinal independent from the display
          local ordinal = display

          return {
            value = entry,
            display = display,
            ordinal = ordinal,
          }
        end,
      }),
      sorter = config.generic_sorter(opts),
      previewer = previewers.new_buffer_previewer({
        title = 'Zotero Entry Details Better BibTex',
        define_preview = function(self, entry)
          local title = '#'
          if entry.value.title then
            title = title .. ' ' .. entry.value.title
          end
          vim.api.nvim_buf_set_lines(
            self.state.bufnr,
            0,
            0,
            true,
            vim
              .iter({
                title,
                '',
                '```lua',
                vim.split(vim.inspect(entry), '\n'),
                '```',
              })
              :flatten()
              :totable()
          )
          utils.highlighter(self.state.bufnr, 'markdown')
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = actions_state.get_selected_entry()
          actions.close(prompt_bufnr)
          log.debug('Selected', selection)
          local command = {}
        end)
        return true
      end,
    })
    :find()
end

-- M.get_zotero_data_betterbib()
M.show_zotero_bib()

return M
