# cmp-help-tags
Syntax completion for all help tags in Neovim (including your plugins). It uses the same data structure as `:Telescope help_tags`. The plugin targets [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

## Installation and Configuration (Lazy.nvim)
```lua
{
  'PhilippFeO/cmp-help-tags',
  opts = {
    filetypes = {
        ...
    }
  }
}
```
- `filetypes`: Table of filetypes where the completion should be activated, fi. `'markdown'`.

## Enabling within [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
```lua
require("cmp").setup({
  sources = {
    { name = "cmp_help_tags",-- '_' not '-' 😯
      -- recommended to avoid cluttering
      -- keyword_length = 5
    },
  }
})
```
