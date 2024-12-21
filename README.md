# zotero-telescope

Search through your zotero library with telescope. Uses the endpoint from the [newly added](https://groups.google.com/g/zotero-dev/c/ElvHhIFAXrY/m/fA7SKKwsAgAJ) local http server from zotero. Check out the [docs](https://www.zotero.org/support/dev/web_api/v3/basics) for ways to manipulate the api call.

## Installation

### Lazy
```lua
return {
  "beetlejuice16/zotero-telescope.nvim"
-- This is how you can change the parameters of the url
-- https://www.zotero.org/support/dev/web_api/v3/basics
  opts = { 
     base_url = 'http://localhost:23119/api/users/0',
     resources = '/items/top',
     parameters = '?sort=dateModified',
   }, 
  config = function(_, opts)
    require('zotero-telescope').setup(opts)
    -- An example keymap for calling the telescope buffer 
    vim.keymap.set('n', '<leader>zt', ':ZoteroTelescope<CR>')
  end,
}

```


## Usage

1. The plugin sets up a `:ZoteroTelescope` command to call the telescope buffer with the URL set in the `opts` above.
2. You can set up a keymap to call the command as well.
3. With the default setting you will see your entire zotero library and be able to search in it. Currently it only searches the `author` and `title` fields

Will currently only use the first author of an item in the search as well as the preview heading.

# Planned Features

- [ ] Search using the BetterBibtex endpoint
- [ ] Insert citation key when selecting the entry

## License MIT
