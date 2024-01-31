local TelescopeDirectory = {}

local State = {
    ---@type telescope-directory.ExtensionConfig
    config = {
        finder_cmd = nil,
        search_options = {
            feature = nil,
            feature_opts = nil,
            follow = nil,
            hidden = nil,
            no_ignore = nil,
            no_ignore_parent = nil,
            previewer = true,
            previewer_opts = {},
        },
        features = require("telescope-directory.features"),
    },
    registered_features = {},
}

local H = {}

---@alias telescope-directory.FinderCreateCmd fun(opts: telescope-directory.SearchOptions): table
---@alias telescope-directory.FinderCmd nil|"fd"|"fdfind"|"find"|telescope-directory.FinderCreateCmd
---@alias telescope-directory.FeatureCallbackOpts table
---@alias telescope-directory.FeatureCallback fun(dirs: string[], opts: telescope-directory.FeatureCallbackOpts)

---@class telescope-directory.SearchOptions
---@field feature? string Name of feature that should be executed after selection.
---@field feature_opts? telescope-directory.FeatureCallbackOpts Arbitrary options for feature callback. (default: {})
---@field follow? boolean Follow symlinks (default: false)
---@field hidden? boolean Show hidden directories (default: false)
---@field no_ignore? boolean Show directories ignored by .gitignore, .ignore, etc. (default: false)
---@field no_ignore_parent? boolean Show directories ignored by .gitignore, .ignore, etc. in parent directories. (default: false)
---@field previewer? boolean|any Show show directory preview. Can be boolean or telescope previewer. (default: true)
---@field previewer_opts? any Options for previewer.

---@class telescope-directory.Feature
---@field name string
---@field callback telescope-directory.FeatureCallback

---@class telescope-directory.ExtensionConfig
---@field finder_cmd telescope-directory.FinderCmd
---@field search_options telescope-directory.SearchOptions
---@field features telescope-directory.Feature[]

---@param config? telescope-directory.ExtensionConfig
function TelescopeDirectory.setup(config)
    config = H.setup_config(config)
    State.config = config
end

---@param opts? telescope-directory.SearchOptions
function TelescopeDirectory.directory(opts)
    opts = H.resolve_search_options(opts)

    local config = require("telescope.config")
    local actions = require("telescope.actions")
    local action_set = require("telescope.actions.set")
    local action_state = require("telescope.actions.state")

    if nil ~= opts.feature and not vim.tbl_contains(State.registered_features, opts.feature) then
        vim.notify("No feature was specified. Default telescope callback will be executed.", vim.log.levels.WARN)
    end
    local callback = nil
    for _, feature in pairs(State.config.features) do
        if opts.feature == feature.name then
            callback = feature.callback
        end
    end

    require("telescope.pickers")
        .new(opts, {
            prompt_title = "Directory",
            finder = require("telescope-directory.finder").get(State.config.finder_cmd, opts),
            previewer = true == opts.previewer and config.values.file_previewer(opts.previewer_opts or {})
                or opts.previewer,
            sorter = config.values.file_sorter({}),
            attach_mappings = function(prompt_bufnr)
                if nil ~= callback then
                    action_set.select:replace(function()
                        local picker = action_state.get_current_picker(prompt_bufnr)
                        local entries = picker:get_multi_selection()
                        if vim.tbl_isempty(entries) then
                            table.insert(entries, action_state.get_selected_entry())
                        end

                        actions.close(prompt_bufnr)

                        local dirs = vim.tbl_map(function(entry)
                            return entry.value
                        end, entries)
                        callback(dirs, opts.feature_opts or {})
                    end)
                end

                return true
            end,
        })
        :find()
end

H.default_config = vim.deepcopy(State.config)

---@param config? telescope-directory.ExtensionConfig
---@return telescope-directory.ExtensionConfig
function H.setup_config(config)
    H.reset_state()

    config = vim.deepcopy(config or {})
    vim.validate({ config = { config, "table" } })
    config.features = config.features or {}

    local default_config = vim.deepcopy(H.default_config)
    vim.validate({ ["config.features"] = { config.features, "table" } })
    vim.list_extend(config.features, default_config.features)
    config = vim.tbl_deep_extend("force", default_config, config)

    vim.validate({
        ["config.finder_cmd"] = {
            config.finder_cmd,
            function(value)
                return nil == value or "function" == type(value) or vim.tbl_contains({ "fd", "fdfind", "find" }, value)
            end,
            'nil|function|"fd"|"fdfind"|"find"',
        },
    })

    for _, feature in pairs(config.features) do
        vim.validate({
            ["feature"] = { feature, "table" },
            ["feature.name"] = { feature.name, "string" },
            ["feature.callback"] = { feature.callback, "function" },
        })
        State.registered_features[#State.registered_features + 1] = feature.name
    end

    H.validate_search_options(config.search_options)

    return config
end

function H.reset_state()
    State.config = vim.deepcopy(H.default_config)
    State.registered_features = {}
end

---@param opts? telescope-directory.SearchOptions
---@return telescope-directory.SearchOptions
function H.resolve_search_options(opts)
    opts = vim.tbl_deep_extend("force", vim.deepcopy(State.config.search_options), opts or {})
    H.validate_search_options(opts)

    return opts
end

---@param opts? telescope-directory.SearchOptions
function H.validate_search_options(opts)
    opts = opts or {}
    vim.validate({
        opts = { opts, "table" },
        ["opts.feature"] = { opts.feature, "string", true },
        ["opts.feature_opts"] = { opts.feature_opts, "table", true },
        ["opts.follow"] = { opts.follow, "boolean", true },
        ["opts.hidden"] = { opts.hidden, "boolean", true },
        ["opts.no_ignore"] = { opts.no_ignore, "boolean", true },
        ["opts.no_ignore_parent"] = { opts.no_ignore_parent, "boolean", true },
    })
end

return TelescopeDirectory
