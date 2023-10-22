# :telescope: telescope-jumps.nvim
Jumps in change and jump lists in the current file.

# Installation

### lazy.nvim
```lua
 'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
        { 'amiroslaw/telescope-jumps.nvim' },
    },
},
```

### Vim-Plug

```viml
Plug "nvim-telescope/telescope.nvim"
Plug "amiroslaw/telescope-jumps.nvim"
```

# Setup and Configuration

```lua
require('telescope').load_extension('changes')
require('telescope').load_extension('jumpbuff')
```

# Usage
`:Telescope changes`
`:Telescope jumpbuff`

Plugin is inspired by the extension [LinArcX](https://github.com/LinArcX/telescope-jumps.nvim), and buildin finder `jumps`
