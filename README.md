# pickup.nvim

tani's fuzzy finder

# Usage

This plugin depens on [nui.nvim](https://github.com/MunifTanjim/nui.nvim).

```lua
use {
  'tani/pickup.nvim',
  requires = { 'MunifTanjim/nui.nvim' },
  config = function()
    require('pickup.nvim').setup()
  end
}
```

- `<C-p>` or `[lhs]`: to select a file
- `<C-c>`: to cancel the selection

# License

MIT License.
