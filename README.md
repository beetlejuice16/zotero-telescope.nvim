# zotero-telescope

Search through your zotero library with telescope. Uses the endpoint from the [newly added](https://groups.google.com/g/zotero-dev/c/ElvHhIFAXrY/m/fA7SKKwsAgAJ) local http server from zotero. Check out the [docs](https://www.zotero.org/support/dev/web_api/v3/basics) for ways to manipulate the api call.

## Acknowledgements

Shout out to @krisajenkins https://github.com/krisajenkins for the great [youtube video](https://www.youtube.com/watch?v=HXABdG3xJW4&t=183s) that is the basis of this project.

Also shout out to @tjdevries https://github.com/tjdevries for the amazing [`telescope`](https://github.com/nvim-telescope/telescope.nvim) plugin and the extremely helpful [youtube video](https://www.youtube.com/watch?v=xdXE1tOT-qg).

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
