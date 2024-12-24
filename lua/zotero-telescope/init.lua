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
local better_bib = require('zotero-telescope.betterbib')

local M = {}

local default_opts = {
  base_url = 'http://localhost:23119/api/users/0',
  resources = '/items/top',
  parameters = '?sort=dateModified',
}

---@param entry_authors table pass the entry creators table from the finder here
---@return table
M._check_and_format_authors = function(entry_authors)
  local authors = entry_authors
  local list_authors = {}
  if authors then
    if next(authors) then
      for _, v in ipairs(authors) do
        if v.name then
          table.insert(list_authors, v.name)
        end
        if v.firstName and v.lastName then
          table.insert(list_authors, v.lastName .. ', ' .. v.firstName)
        end
      end
      return list_authors
    end
    return {}
  end
  return {}
end

---@param base_url? string Default: "http://localhost:23119/api/users/0"
---@param resources? string Default: "/items/top" see [zotero web api docs](https://www.zotero.org/support/dev/web_api/v3/basics#resources)
---@param parameters? string Default: "?&sort=dateModified" see section on [url parameters](https://www.zotero.org/support/dev/web_api/v3/basics#read_requests)
---@return table
M._get_zotero_data = function(base_url, resources, parameters)
  local api_endpoint = base_url .. resources .. parameters
  local response = curl.get(api_endpoint)
  local data = response.body
  local parsed_data = vim.json.decode(data, { array = true })
  return parsed_data
end

M.zotero_telescoper = function(opts)
  pickers
    .new({}, {
      finder = finders.new_table({
        results = M._get_zotero_data(
          default_opts.base_url,
          default_opts.resources,
          default_opts.parameters
        ),
        entry_maker = function(entry)
          local display = entry.data.title

          local list_authors = M._check_and_format_authors(entry.data.creators)
          local ordinal = display .. vim.fn.join(list_authors, '; ')

          if #list_authors == 1 then
            display = list_authors[1] .. ' - ' .. display
          end
          if #list_authors > 1 then
            display = list_authors[1] .. ' et al.' .. ' - ' .. display
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
        title = 'Zotero Entry Details',
        define_preview = function(self, entry)
          vim.api.nvim_buf_set_lines(
            self.state.bufnr,
            0,
            0,
            true,
            vim
              .iter({
                '# Title: ' .. entry.value.data.title,

                '# Authors: '
                  .. vim.fn.join(M._check_and_format_authors(entry.value.data.creators), '; '),
                '',

                '```lua',
                vim.split(vim.inspect(entry.value), '\n'),
                '```',
              })
              :flatten()
              :totable()
          )
          utils.highlighter(self.state.bufnr, 'markdown')
        end,
      }),
      -- TODO: Think of command for vanilla zotero search
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = actions_state.get_selected_entry()
          actions.close(prompt_bufnr)
          local command = {}
        end)
        return true
      end,
    })
    :find()
end

M.setup = function(opts)
  -- TODO: Improve on how the function calls accept parameters from the user
  default_opts = vim.tbl_deep_extend('force', default_opts, opts)

  vim.api.nvim_create_user_command('ZoteroTelescope', M.zotero_telescoper, {})
  vim.api.nvim_create_user_command('ZoteroCite', better_bib.better_bib_cite, {})
end

return M
