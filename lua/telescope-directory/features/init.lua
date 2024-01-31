local util = require("telescope-directory.features.util")

---@type telescope-directory.Feature[]
return {
    util.create_builtin_with_search_dirs("fd"),
    util.create_builtin_with_search_dirs("find_files"),
    util.create_builtin_with_search_dirs("grep_string"),
    util.create_builtin_with_search_dirs("live_grep"),
}
