local function get_default_exports()
    local exports = {}
    exports.directory = function(opts)
        require("telescope-directory").directory(opts)
    end
    for _, feature in pairs(require("telescope-directory.features")) do
        exports[feature.name] = function(opts)
            opts.feature = feature.name
            require("telescope-directory").directory(opts)
        end
    end
    return exports
end

local extension_loaded = false

return require("telescope").register_extension({
    setup = function(ext_opts)
        if not extension_loaded then
            extension_loaded = true
            require("telescope-directory").setup(ext_opts)
        end
    end,
    exports = get_default_exports(),
})
