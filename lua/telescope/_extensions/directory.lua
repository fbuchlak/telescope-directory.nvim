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

return require("telescope").register_extension({
    setup = function(ext_opts)
        require("telescope-directory").setup(ext_opts)
    end,
    exports = get_default_exports(),
})
