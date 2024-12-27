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

---@param bibtex_url? string Default: "http://localhost:23119/better-bibtex/library?/1/library.json" see zotero-better-bibtex docs https://retorque.re/zotero-better-bibtex/exporting/pull/index.html
---@return table
M._get_zotero_data_betterbib = function(bibtex_url)
  local api_endpoint = bibtex_url or 'http://localhost:23119/better-bibtex/library?/1/library.json'
  local response = curl.get(api_endpoint)
  local parsed_data = vim.json.decode(response.body, { array = true })
  return parsed_data
end

M.better_bib_cite = function(opts)
  pickers
    .new(opts, {
      finder = finders.new_table({
        results = M._get_zotero_data_betterbib(),
        entry_maker = function(entry)
          local display = entry.title
          local authors = entry.author

          local list_authors = {}
          if authors then
            if next(authors) then
              for _, v in pairs(authors) do
                if v.family and v.given then
                  table.insert(list_authors, v.family .. ', ' .. v.given)
                elseif v.literal then
                  table.insert(list_authors, v.literal)
                end
              end
            end
          end

          local all_authors = vim.iter(list_authors):join('; ')
          entry.all_authors = all_authors

          local ordinal = display .. all_authors

          if #list_authors == 1 then
            display = list_authors[1] .. ' - ' .. display
          elseif #list_authors > 1 then
            display = list_authors[1] .. ' et al. - ' .. display
          end

          return {
            value = entry,
            display = display,
            ordinal = ordinal,
          }
        end,
      }),
      sorter = config.generic_sorter(opts),
      previewer = previewers.new_buffer_previewer({
        title = 'Zotero Entry Details - Better BibTex',
        define_preview = function(self, entry)
          local function set_previewer_contents()
            local title = entry.value.title
            if title then
              title = '# Title: ' .. entry.value.title
            end
            local authors = entry.value.all_authors
            if authors then
              authors = '# Authors: ' .. authors
            end
            return vim
              .iter({
                title,
                authors,
                '```lua',
                vim.split(vim.inspect(entry.value), '\n'),
                '```',
                '',
              })
              :flatten()
              :totable()
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, set_previewer_contents())
          utils.highlighter(self.state.bufnr, 'markdown')
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = actions_state.get_selected_entry()
          local citation_key = '@' .. selection.value['citation-key']

          actions.close(prompt_bufnr)

          vim.api.nvim_put({ citation_key }, '', true, true)
        end)
        return true
      end,
    })
    :find()
end

return M
