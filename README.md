# telescope-directory.nvim

Search for directories with telescope and perform *any* action.

<!--toc:start-->
- [telescope-directory.nvim](#telescope-directorynvim)
  - [Installation](#installation)
    - [Dependencies](#dependencies)
    - [Telescope extension](#telescope-extension)
    - [Lazy load plugin](#lazy-load-plugin)
  - [Options](#options)
  - [Usage](#usage)
    - [Telescope commands](#telescope-commands)
    - [Lua](#lua)
  - [Create custom features](#create-custom-features)
    - [Print selected directories](#print-selected-directories)
    - [Open selected directory with file explorer](#open-selected-directory-with-file-explorer)
  - [Similar plugins](#similar-plugins)
<!--toc:end-->

## Installation

### Dependencies

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) is required
- [fd](https://github.com/sharkdp/fd) (preferred) or `find` is required

### Telescope extension

If you prefer to load extension with telescope use this setup.

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "fbuchlak/telescope-directory.nvim",
    },
    cmd = "Telescope",
    opts = {
        extensions = {
            -- @type telescope-directory.ExtensionConfig
            directory = {},
        },
    },
    config = function(_, opts)
        require("telescope").setup(opts)
        require("telescope").load_extension("directory")
    end,
    keys = {
        -- Call telescope extension from lua
        {
            "<Leader>fd",
            function()
                require("telescope").extensions.directory.live_grep() -- find_files|grep_string|live_grep
            end,
            desc = "Select directory for Live Grep",
        },
        -- Call telescope extension as command
        {
            "<Leader>fe",
            "<CMD>Telescope directory find_files<CR>", -- "find_files"|"grep_string"|"live_grep"
            desc = "Select directory for Find Files",
        },
    },
},
```

### Lazy load plugin

Use this setup if you prefer to lazy load this plugin.
`Telescope` won't have extension loaded until you trigger it with call (e.g. `Telescope directory live_grep`).

[lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "fbuchlak/telescope-directory.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    -- @type telescope-directory.ExtensionConfig
    opts = {},
    config = function(_, opts)
        require("telescope-directory").setup(opts)
    end,
    keys = {
        {
            "<Leader>fd",
            function()
                require("telescope-directory").directory({
                    feature = "live_grep", -- "find_files"|"grep_string"|"live_grep"
                })
            end,
            desc = "Select directory for Live Grep",
        },
        {
            "<Leader>fe",
            "<CMD>Telescope directory find_files<CR>", -- "find_files"|"grep_string"|"live_grep"
            desc = "Select directory for Find Files",
        },
    }
},
```

## Options

```lua
-- @type telescope-directory.SearchOptions
local search_options = {
    feature = nil, -- string|nil - Name of feature that should be executed after selection.
    feature_opts = nil, -- table|nil - Arbitrary options for feature callback. (default: {})
    follow = nil, -- boolean|nil - Follow symlinks (default: false)
    hidden = nil, -- boolean|nil - Show hidden directories (default: false)
    no_ignore = nil, -- boolean|nil - Show directories ignored by .gitignore, .ignore, etc. (default: false)
    no_ignore_parent = nil, -- boolean|nil - Show directories ignored by .gitignore, .ignore, etc. in parent directories. (default: false)
    previewer = true, -- boolean|nil - Show show directory preview. Can be boolean or telescope previewer. (default: true)
    previewer_opts = {}, -- any - Options for previewer.
}

-- @type telescope-directory.ExtensionConfig
local config = {
    finder_cmd = nil, -- nil = autodetect, "fd" | "fdfind" | "find" | fun(opts: SearchOptions): table
    search_options = search_options,
    features = nil, -- table of features ({ name = "name", callback = function(dirs, feature_opts) end })
}
```

## Usage

### Telescope commands

- `Telescope directory find_files previewer=false`
- `Telescope directory live_grep theme=dropdown`
- `Telescope directory grep_string`
- `Telescope directory feature=custom_feature`

### Lua

```lua
-- call feature
require("telescope-directory").directory({ feature = "find_files" })
-- or with options
-- @type telescope-directory.SearchOptions
local search_options = {
    feature = "live_grep",
    feature_opts = {
        -- options for `live_grep` feature
        hidden = true,
        no_ignore = true,
    }
    -- options for `directory` search
    hidden = true,
    no_ignore = true,
}
require("telescope-directory").directory(search_options)
```

## Create custom features

### Print selected directories

```lua
-- setup
require("telescope-directory").setup({
    features = {
        {
            name = "myprint",
            callback = function(dirs)
                vim.print(dirs)
            end
        },
    }
})

require("telescope-directory").directory({ feature = "myprint" })
-- or call `Telescope directory feature=myprint` command
```

### Open selected directory with file explorer

```lua
-- setup
require("telescope-directory").setup({
    features = {
        {
            name = "open_in_file_explorer",
            callback = function(dirs, feature_opts)
                local dir = dirs[1] -- open single directory (ignore multiple selection)

                -- 1. netrw
                vim.cmd(("Vex %s"):format(dir))

                -- 2. https://github.com/echasnovski/mini.files
                -- require("mini.files").open(dir)

                -- 3. https://github.com/stevearc/oil.nvim
                -- require("oil").open(dir)
                -- or
                -- require("oil").open_float(dir)
            end
        },
    }
})

require("telescope-directory").directory({ feature = "open_in_file_explorer" })
```

## Similar plugins

- [dir-telescope.nvim](https://github.com/princejoogie/dir-telescope.nvim)
- [telescope-pathogen.nvim](https://github.com/brookhong/telescope-pathogen.nvim)
- [telescope-search-dir-picker.nvim](https://github.com/smilovanovic/telescope-search-dir-picker.nvim)
