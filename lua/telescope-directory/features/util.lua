local M = {}

---@param name "fd"|"find_files"|"grep_string"|"live_grep"
---@return telescope-directory.Feature
function M.create_builtin_with_search_dirs(name)
    return {
        name = name,
        callback = function(dirs, feature_opts)
            feature_opts = vim.tbl_deep_extend("force", feature_opts or {}, { search_dirs = dirs })
            require("telescope.builtin")[name](feature_opts)
        end,
    }
end

return M
